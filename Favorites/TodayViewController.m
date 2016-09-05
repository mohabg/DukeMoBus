//
//  TodayViewController.m
//  Favorites
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "SharedMethods.h"
#import "APIHandler.h"
#import "BusParser.h"
#import "BusRoute.h"
#import "BusStop.h"
#import "SharedMethods.h"
#import "FavoriteStop.h"
#import "FavoriteStopTableViewCell.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NSMutableArray<FavoriteStop*> * favoriteStops;

//@property (nonatomic, strong) NSMutableArray * favoriteStopIds;
//@property (nonatomic, strong) NSMutableArray * favoriteBusIds;
//@property (nonatomic, strong) NSMutableArray * arrivalTimes;

//@property (nonatomic, strong) NSDictionary<NSString *, NSArray<BusRoute*> *> * favorites;

@property (nonatomic, strong) NSArray<BusRoute*> * favoriteBusRoutes;

@property (nonatomic, strong) NSArray<BusStop*> * favoriteBusStops;

//@property (nonatomic, strong) NSDictionary * stopIdToStopNames;

@property (strong, nonatomic) IBOutlet UITableView * tableview;
@property (strong, nonatomic) IBOutlet UILabel * updatedAtLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableview registerNib:[UINib nibWithNibName:@"FavoriteStopTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FavoriteStopTableViewCell"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    self.tableview.estimatedRowHeight = 44.0;
        
    [self unarchiveFavorites];
    
    //self.stopIdToStopNames = [customDefaults dictionaryForKey:@"stopIdToStopNames"];
   // self.busIdToBusNames = [customDefaults dictionaryForKey:@"busIdToBusNames"];
    
   // [self refreshStops];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    if(!self.favoriteBusStops || !self.favoriteBusRoutes){
        
        completionHandler(NCUpdateResultFailed);
    }
    
    else{
        
        [self refreshStops];
        
        completionHandler(NCUpdateResultNewData);
    }
}

-(void)refreshStops{

    if(!self.favoriteBusStops || !self.favoriteBusRoutes){
        return;
    }
    
    NSMutableArray * stopIds = [NSMutableArray array];
    NSMutableArray * busIds = [NSMutableArray array];

    for(int i = 0; i < [self.favoriteStops count]; i++){
        
        [stopIds addObject:[self.favoriteBusStops objectAtIndex:i].stopID];
        [busIds addObject:[self.favoriteBusRoutes objectAtIndex:i].routeId];
    }
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:stopIds Buses:busIds] CompletionBlock:^(NSDictionary * json) {
        
        for(NSDictionary * data in [json objectForKey:@"data"]){
            
           NSString * stopTitle = [self getStopNameForId:[data objectForKey:@"stop_id"]];
            
            NSDictionary * routesToArrivals = [BusParser parseArrivalsAndRoutes:[data objectForKey:@"arrivals"]];
            
            for(NSString * routeId in [routesToArrivals allKeys]){
                
                NSString * arrivalTime = [SharedMethods walkingTimeString:[routesToArrivals objectForKey:routeId]];
                
                NSString * routeTitle = [self getRouteNameForId:routeId];
                        
                FavoriteStop * favorite = [[FavoriteStop alloc] initWithBusTitle:routeTitle StopTitle:stopTitle ArrivalTime:arrivalTime];
                [self.favoriteStops addObject:favorite];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateTimeLabel];
            
            [self updateWidgetDisplay];
           
        });
    }];
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numRows = [self.favoriteStops count];
//    if(numRows >= 1){
//        FavoriteStopTableViewCell * cell = (FavoriteStopTableViewCell *) [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        CGFloat cellHeight = [cell cellHeight];
//        CGFloat tableViewHeight = cellHeight * numRows;
//        
//        self.preferredContentSize = CGSizeMake(self.tableview.contentSize.width, tableViewHeight + self.updatedAtLabel.frame.size.height);
//
//    }
    return numRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FavoriteStopTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteStopTableViewCell"];
    
    NSInteger row = indexPath.row;
    
    FavoriteStop * favorite = [_favoriteStops objectAtIndex:row];
    cell.busTitleLabel.text = [SharedMethods getUserFriendlyBusTitle:favorite.busTitle];
    cell.stopNameLabel.text =  [SharedMethods getUserFriendlyStopName:favorite.stopTitle];
    cell.arrivalTimeLabel.text = @"None";
    
    if(favorite.arrivalTime){
        cell.arrivalTimeLabel.text = favorite.arrivalTime;
    }
    
//    NSString * busTitle = [_busIdToBusNames objectForKey:[_favoriteBusIds objectAtIndex:row]];
//    NSString * stopTitle = [_stopIdToStopNames objectForKey:[_favoriteStopIds objectAtIndex:row]];
//    
//    cell.busTitleLabel.text = [self getUserFriendlyBusTitle:busTitle];
//    cell.stopNameLabel.text = [SharedMethods getUserFriendlyStopName:stopTitle];
//    cell.arrivalTimeLabel.text = @"None";
//    
//    if(row < [_arrivalTimes count]){
//        NSString * arrivalTime = [_arrivalTimes objectAtIndex:row];
//        cell.arrivalTimeLabel.text = arrivalTime;
//    }
//    
    return cell;
}

#pragma mark - Misc

-(void)updateTimeLabel{
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    self.updatedAtLabel.text = [NSString stringWithFormat:@"Last Update: %@", [formatter stringFromDate:[NSDate date]]];
}

//-(void)populateFavorites{
//    
//    _favoriteStopIds = [NSMutableArray array];
//    _favoriteBusIds = [NSMutableArray array];
//    _arrivalTimes = [NSMutableArray array];
//    
//    for(NSString * stopId in [self.favorites allKeys]){
//        [_favoriteStopIds addObject:stopId];
//        
//        for(NSString * busId in [self.favorites objectForKey:stopId]){
//            [_favoriteBusIds addObject:busId];
//        }
//    }
//}

-(void)unarchiveFavorites{
    
    self.favoriteBusRoutes = [SharedMethods unarchiveFavRoutes];
    self.favoriteBusStops = [SharedMethods unarchiveFavStops];
    
//    
////    self.favoriteStops = [[customDefaults objectForKey:@"favoriteStops"] mutableCopy];
////    if(!self.favoriteStops){
////        self.favoriteStops = [NSMutableArray array];
////    }
//    self.stopIdToStopNames = [customDefaults dictionaryForKey:@"favStopIdsToStopNames"];
//    self.favorites = [customDefaults dictionaryForKey:@"favorites"];
//    
//    //Convert Data
//    NSMutableDictionary * unarchivedFavorites = [NSMutableDictionary dictionary];
//    
//    for(NSString * stopId in [self.favorites allKeys]){
//        NSMutableArray * unarchivedRoutes = [NSMutableArray array];
//        
//        for(NSData * routesData in [self.favorites objectForKey:stopId]){
//            
//            [unarchivedRoutes addObject:[NSKeyedUnarchiver unarchiveObjectWithData:routesData]];
//        }
//        [unarchivedFavorites setObject:unarchivedRoutes forKey:stopId];
//    }
//    
//    self.favorites = unarchivedFavorites;
}

-(void)updateWidgetDisplay{
    
    [self.tableview reloadData];
    self.tableview.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat labelHeight = [self.updatedAtLabel sizeThatFits:self.updatedAtLabel.frame.size].height;
    //Size = TableView + Time Label
    self.preferredContentSize = CGSizeMake(self.tableview.contentSize.width, self.tableview.contentSize.height + labelHeight + 10);
}

-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    
    return UIEdgeInsetsMake(defaultMarginInsets.top, 5.0, 5.0, defaultMarginInsets.right);
}

-(NSString *)getStopNameForId:(NSString *)stopId{
    
    for(BusStop * favStop in self.favoriteStops){
        if([favStop.stopID isEqualToString:stopId]){
            
            return favStop.stopName;
        }
    }
    return nil;
}

-(NSString *)getRouteNameForId:(NSString *)routeId{
    
    for(BusRoute * favRoute in self.favoriteBusRoutes){
        if([favRoute.routeId isEqualToString:routeId]){
            
            return favRoute.routeName;
        }
    }
    return nil;
}
@end

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
#import "SharedMethods.h"
#import "FavoriteStop.h"
#import "FavoriteStopTableViewCell.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NSMutableArray<FavoriteStop*> * favoriteStops;

//@property (nonatomic, strong) NSMutableArray * favoriteStopIds;
//@property (nonatomic, strong) NSMutableArray * favoriteBusIds;
//@property (nonatomic, strong) NSMutableArray * arrivalTimes;

@property (nonatomic, strong) NSDictionary * favorites;
@property (nonatomic, strong) NSDictionary * stopIdToStopNames;
@property (nonatomic, strong) NSDictionary * busIdToBusNames;

@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UILabel *updatedAtLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableview registerNib:[UINib nibWithNibName:@"FavoriteStopTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FavoriteStopTableViewCell"];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    NSUserDefaults * customDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.DukeMoBus"];

    self.favorites = [customDefaults dictionaryForKey:@"favoriteStops"];
    self.stopIdToStopNames = [customDefaults dictionaryForKey:@"stopIdToStopNames"];
    self.busIdToBusNames = [customDefaults dictionaryForKey:@"busIdToBusNames"];
    
   // [self refreshStops];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    if(!self.favorites || !self.stopIdToStopNames || !self.busIdToBusNames){
        
        completionHandler(NCUpdateResultFailed);
    }
    
    else{
        
        [self refreshStops];
        
        completionHandler(NCUpdateResultNewData);
    }
}

-(void)refreshStops{

    if(!self.favorites || !self.stopIdToStopNames || !self.busIdToBusNames){
        return;
    }
    
    //[self populateFavorites];
    
    NSArray * stopIds = [self.favorites allKeys];
    NSMutableArray * busIds = [NSMutableArray array];
    
    for(NSArray * buses in [self.favorites allValues]){
        [busIds addObjectsFromArray:buses];
    }
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:stopIds Buses:busIds] CompletionBlock:^(NSDictionary * json) {
        
        self.favoriteStops = [NSMutableArray array];
        
        for(NSDictionary * data in [json objectForKey:@"data"]){
            
            NSString * stopTitle = [self.stopIdToStopNames objectForKey:[data objectForKey:@"stop_id"]];
            
            NSDictionary * routesToArrivals = [BusParser parseArrivalsAndRoutes:[data objectForKey:@"arrivals"]];
            
            //In case multiple routes for one stop
            for(NSString * routeId in [routesToArrivals allKeys]){
                
                NSString * arrivalTime = [SharedMethods walkingTimeString:[routesToArrivals objectForKey:routeId]];
                
                NSString * busTitle = [_busIdToBusNames objectForKey:routeId];
                FavoriteStop * favorite = [[FavoriteStop alloc] initWithBusTitle:busTitle StopTitle:stopTitle ArrivalTime:arrivalTime];
                [self.favoriteStops addObject:favorite];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateWidgetDisplay];
           
            [self updateTimeLabel];
        });
    }];
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        
    return [self.favoriteStops count];
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

-(void)updateWidgetDisplay{
    
    [self.tableview reloadData];
    self.tableview.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Size = TableView + Time Label
    self.preferredContentSize = CGSizeMake(self.tableview.contentSize.width, self.tableview.contentSize.height + self.updatedAtLabel.frame.size.height);
}
@end

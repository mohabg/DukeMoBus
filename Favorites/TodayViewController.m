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
#import "FavoriteStop.h"
#import "FavoriteStopTableViewCell.h"

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) NSMutableArray<FavoriteStop*> * favoriteStops;

@property (strong, nonatomic) IBOutlet UITableView *tableview;
//@property (strong, nonatomic) IBOutlet UILabel *updatedAtLabel;

@property (nonatomic, strong) NSDictionary * favorites;
@property (nonatomic, strong) NSDictionary * stopIdToStopNames;
@property (nonatomic, strong) NSDictionary * busIdToBusNames;


@end

@implementation TodayViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"VIEW WILL APPEAR CALLED");
    
}

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
    
   // self.updatedAtLabel.text = @"Updated At: 3:15 PM";
    
    [self refreshStops];
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
    
    NSMutableArray * favoriteStopIds = [NSMutableArray array];
    NSMutableArray * favoriteBusIds = [NSMutableArray array];
    
    for(NSString * stopId in [self.favorites allKeys]){
        [favoriteStopIds addObject:stopId];
        
        for(NSString * busId in [self.favorites objectForKey:stopId]){
            [favoriteBusIds addObject:busId];
        }
    }
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:favoriteStopIds Buses:favoriteBusIds] CompletionBlock:^(NSDictionary * json) {
        
        self.favoriteStops = [NSMutableArray array];
        
        for(NSDictionary * data in [json objectForKey:@"data"]){
            
            NSString * stopTitle = [self.stopIdToStopNames objectForKey:[data objectForKey:@"stop_id"]];
            
            NSDictionary * routesToArrivals = [BusParser parseArrivalsAndRoutes:[data objectForKey:@"arrivals"]];
            
            for(NSString * routeId in [routesToArrivals allKeys]){
                //If multiple routes for one stop
                NSString * busTitle = [self.busIdToBusNames objectForKey:routeId];
                NSString * arrivalTime = [routesToArrivals objectForKey:routeId];
                FavoriteStop * favorite = [[FavoriteStop alloc] initWithBusTitle:busTitle StopTitle:stopTitle ArrivalTime:arrivalTime];
                
                [self.favoriteStops addObject:favorite];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableview reloadData];
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
    
    FavoriteStop * favoriteStop = [self.favoriteStops objectAtIndex:indexPath.row];
    
    cell.busTitleLabel.text = [favoriteStop getUserFriendlyBusTitle];
    cell.stopNameLabel.text = favoriteStop.stopTitle;
    cell.arrivalTimeLabel.text = favoriteStop.arrivalTime;
    
    return cell;
}

@end

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
@property (strong, nonatomic) IBOutlet UILabel *updatedAtLabel;


@end

@implementation TodayViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"SHOWING");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"SHOWING DID");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableview registerNib:[UINib nibWithNibName:@"FavoriteStopTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FavoriteStopTableViewCell"];
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
    
    NSDictionary * favorites = [NSKeyedUnarchiver unarchiveObjectWithFile:[SharedMethods getArchivePathUsingString:@"favorites.archive"]];
    NSDictionary * stopIdToStopNames = [NSKeyedUnarchiver unarchiveObjectWithFile:[SharedMethods getArchivePathUsingString:@"stopIdToStopNames.archive"]];
    NSDictionary * busIdToBusNames = [NSKeyedUnarchiver unarchiveObjectWithFile:[SharedMethods getArchivePathUsingString:@"busIdToBusNames.archive"]];
    
    if(!favorites || !stopIdToStopNames || !busIdToBusNames){
        
        completionHandler(NCUpdateResultFailed);
    }
    
    NSMutableArray * favoriteStopIds = [NSMutableArray array];
    NSMutableArray * favoriteBusIds = [NSMutableArray array];
    
    for(NSString * stopId in [favorites allKeys]){
        [favoriteStopIds addObject:stopId];
        
        for(NSString * busId in [favorites objectForKey:stopId]){
            [favoriteBusIds addObject:busId];
        }
    }
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:favoriteStopIds Buses:favoriteBusIds] CompletionBlock:^(NSDictionary * json) {
        
        self.favoriteStops = [NSMutableArray array];
        
        for(NSDictionary * data in [json objectForKey:@"data"]){
           
            NSString * stopId = [stopIdToStopNames objectForKey:[data objectForKey:@"stop_id"]];
            NSString * stopTitle = [stopIdToStopNames objectForKey:stopId];

            NSDictionary * routesToArrivals = [BusParser parseArrivalsAndRoutes:[data objectForKey:@"arrivals"]];
            
            for(NSString * routeId in [routesToArrivals allKeys]){
                //If multiple routes for one stop
                NSString * busTitle = [busIdToBusNames objectForKey:routeId];
                NSString * arrivalTime = [routesToArrivals objectForKey:routeId];
                FavoriteStop * favorite = [[FavoriteStop alloc] initWithBusTitle:busTitle StopTitle:stopTitle ArrivalTime:arrivalTime];
                
                [self.favoriteStops addObject:favorite];
            }
        }
        
        [self.tableview reloadData];
    }];
    
    completionHandler(NCUpdateResultNewData);
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

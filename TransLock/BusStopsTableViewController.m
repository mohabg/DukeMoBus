//
//  BusStopsTableViewController.m
//  Pods
//
//  Created by Mohab Gabal on 8/13/16.
//
//

#import "BusStopsTableViewController.h"
#import "BusStopsTableViewCell.h"
#import "APIHandler.h"
#import "BusStop.h"
#import "BusParser.h"

static NSString * cellIdentifier = @"BusStopsTableViewCell";

@interface BusStopsTableViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;


@property (nonatomic, strong) NSArray * stopNames;
@property (nonatomic, strong) NSMutableArray<BusStop *> * busStops;

//Used to wait until all async requests are finished
@property (nonatomic, strong) dispatch_group_t dispatch;

@end

@implementation BusStopsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationController.navigationBar.hidden = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusStopsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.busStops count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusStopsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
   
    BusStop * stop = [self.busStops objectAtIndex:indexPath.row];
    
    cell.busStopNameLabel.text = stop.stopName;
    if(stop.walkTime){
        cell.busStopWalkingLabel.text = [NSString stringWithFormat:@"%@ walking",stop.walkTime];
    }
    
    //This could be done more elegantly, but that would be a waste of time.
    switch ([stop.arrivalTimes count]) {
        case 0:
            cell.firstBusTimeLabel.text = @"N/A";
            cell.secondBusTimeLabel.text = @"";
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 1:
            cell.firstBusTimeLabel.text = [self walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = @"";
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 2:
            cell.firstBusTimeLabel.text = [self walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = [self walkingTimeString:[stop.arrivalTimes objectAtIndex:1]];
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 3:
            cell.firstBusTimeLabel.text = [self walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = [self walkingTimeString:[stop.arrivalTimes objectAtIndex:1]];
            cell.thirdBusTimeLabel.text = [self walkingTimeString:[stop.arrivalTimes objectAtIndex:2]];
            break;
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.30]];
    
    return cell;
}


-(void)findStopsForBusId:(NSString *)busId{
    self.dispatch = dispatch_group_create();
    if(!_busStops){
        _busStops = [NSMutableArray array];
    }
    
    NSMutableArray * stopIds = [NSMutableArray array];
    NSMutableDictionary<NSString *, BusStop *> * stopIdToBusStop = [NSMutableDictionary dictionary];
    
    CLLocation * from = [[CLLocation alloc] initWithLatitude:[self.busData.userLatitude doubleValue]  longitude:[self.busData.userLongitude doubleValue]];
    NSMutableArray * destinationsLoc = [NSMutableArray array];
    for(BusStop * busStop in [self.busData getNearbyStops]){
        
        for(NSString * busIdAtStop in busStop.busIDs){
            
            if([busIdAtStop isEqualToString:busId]){
                
                [self.busStops addObject:busStop];
                [stopIds addObject:busStop.stopID];
                [stopIdToBusStop setObject:busStop forKey:busStop.stopID];
                
                CLLocation * to = [[CLLocation alloc] initWithLatitude:[busStop.latitude doubleValue]  longitude:[busStop.longitude doubleValue]];
                [destinationsLoc addObject:to];
            }
        }
    }
    dispatch_group_enter(self.dispatch);
    
    [APIHandler parseJsonWithRequest:[APIHandler createWalkTimeRequestFromLocation:from ToLocations:destinationsLoc]                CompletionBlock:^(NSDictionary * json) {
        
        NSArray * walkTimes = [BusParser parseWalkTimes:json];
        for(int i = 0; i < [self.busStops count]; i++){
            [self.busStops objectAtIndex:i].walkTime = [walkTimes objectAtIndex:i];
        }
            dispatch_group_leave(self.dispatch);
    }];
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:stopIds Buses:[NSArray arrayWithObject:busId]] CompletionBlock:^(NSDictionary * json) {
        
        for(NSDictionary * data in [json objectForKey:@"data"]){
            BusStop * busStop = [stopIdToBusStop objectForKey:[data objectForKey:@"stop_id"]];
            NSArray * arrivalTimes = [BusParser parseArrivals:[data objectForKey:@"arrivals"]];
            busStop.arrivalTimes = arrivalTimes;
        }
        dispatch_group_wait(self.dispatch, DISPATCH_TIME_FOREVER);
        self.busStops = [[self.busStops sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        [self.tableView reloadData];
    }];
}

-(NSString *)walkingTimeString:(NSString *)walkTime{
    NSInteger walkTimeInt = [walkTime integerValue];
    
    if(walkTimeInt <= 1){
        
        return @"1 min";
    }
    return [NSString stringWithFormat:@"%@ mins", walkTime];
}
@end

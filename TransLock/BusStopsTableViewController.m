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

@end

@implementation BusStopsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationController.navigationBar.hidden = NO;
    
    _busStops = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusStopsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    
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
    cell.busStopWalkingLabel.text = stop.walkTime;
    
    //Could be done more elegantly but that would be a waste of time
    switch ([stop.arrivalTimes count]) {
        case 0:
            cell.firstBusTimeLabel.text = @"N/A";
            cell.secondBusTimeLabel.text = @"";
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 1:
            cell.firstBusTimeLabel.text = [stop.arrivalTimes objectAtIndex:0];
            cell.secondBusTimeLabel.text = @"";
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 2:
            cell.firstBusTimeLabel.text = [stop.arrivalTimes objectAtIndex:0];
            cell.secondBusTimeLabel.text = [stop.arrivalTimes objectAtIndex:1];
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 3:
            cell.firstBusTimeLabel.text = [stop.arrivalTimes objectAtIndex:0];
            cell.secondBusTimeLabel.text = [stop.arrivalTimes objectAtIndex:1];
            cell.thirdBusTimeLabel.text = [stop.arrivalTimes objectAtIndex:2];
            break;
    }
    
    return cell;
}


-(void)findStopsForBusId:(NSString *)busId{
    NSMutableArray * stopIds = [NSMutableArray array];
    
    for(BusStop * busStop in self.busData.nearbyBusStops){
        
        for(NSString * busIdAtStop in busStop.busIDs){
            
            if([busIdAtStop isEqualToString:busId]){
                [self.busStops addObject:busStop];
                [stopIds addObject:busStop.stopID];
            }
        }
    }
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:stopIds Buses:[NSArray arrayWithObject:busId]] CompletionBlock:^(NSDictionary * json) {
        
        [BusParser parseData:[json objectForKey:@"data"] IntoBusData:self.busData ForBusId:busId];
        
        
        [self.tableView reloadData];
    }];
}
@end

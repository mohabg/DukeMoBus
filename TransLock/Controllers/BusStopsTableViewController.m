//
//  BusStopsTableViewController.m
//  Pods
//
//  Created by Mohab Gabal on 8/13/16.
//
//

#import "BusStopsTableViewController.h"
#import "BusStopsTableViewCell.h"
#import "SharedMethods.h"
#import "APIHandler.h"
#import "BusStop.h"
#import "LocationHandler.h"
#import "BusParser.h"

static NSString * cellIdentifier = @"BusStopsTableViewCell";

@interface BusStopsTableViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSString * tappedBusId;

@property (nonatomic, strong) NSMutableArray<BusStop *> * busStops;

@end

@implementation BusStopsTableViewController

@synthesize tableView;


- (void)viewDidLoad {
    [super viewDidLoad];
      
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
    
    cell.busStopNameLabel.text = [SharedMethods getUserFriendlyStopName:stop.stopName];
    if(stop.walkTime){
        cell.busStopWalkingLabel.text = [NSString stringWithFormat:@"%@ walking",stop.walkTime];
    }
    
    //This could be done more elegantly, but that would be a waste of time.
    switch ([stop.arrivalTimes count]) {
        case 0:
            cell.firstBusTimeLabel.text = @"None";
            cell.secondBusTimeLabel.text = @"";
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 1:
            cell.firstBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = @"";
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 2:
            cell.firstBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:1]];
            cell.thirdBusTimeLabel.text = @"";
            break;
        case 3:
            cell.firstBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:1]];
            cell.thirdBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:2]];
            break;
        default:
            cell.firstBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:0]];
            cell.secondBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:1]];
            cell.thirdBusTimeLabel.text = [SharedMethods walkingTimeString:[stop.arrivalTimes objectAtIndex:2]];
            break;
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.30]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BusStop * selectedStop = [self.busStops objectAtIndex:indexPath.row];
    
    NSString * favoritesAlertTitle = @"Add to favorites";
    
    void (^favoritesHandler)(UIAlertAction * _Nonnull) = ^void (UIAlertAction * _Nonnull action){
        
        [self.busData addFavoriteBus:_tappedBusId ForStop:selectedStop.stopID];
    };
    
    NSDictionary * favoriteStops = [self.busData getFavoriteBusesForStop];
    
    for(NSString * favoriteStop in [favoriteStops allKeys]){
        
        if([favoriteStop isEqualToString:selectedStop.stopID]){
            
            if([[favoriteStops objectForKey:favoriteStop] containsObject:_tappedBusId]){
                
                favoritesAlertTitle = @"Remove from favorites";
                
                favoritesHandler = ^void (UIAlertAction * _Nonnull action){
                    
                    [self.busData removeFavoriteBus:_tappedBusId ForStop:favoriteStop];
                };
            }
        }
    }
    
    UIAlertController * alerter = [UIAlertController alertControllerWithTitle:@"" message:@"Add this stop to your favorites to display it in your today widget, or get directions" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * favoritesAction = [UIAlertAction actionWithTitle:favoritesAlertTitle style:UIAlertActionStyleDefault handler:favoritesHandler];
    
    UIAlertAction * mapsAction = [UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@&dirflg=w", @"36.004162", @"-78.931327", selectedStop.latitude, selectedStop.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alerter addAction:favoritesAction];
    [alerter addAction:mapsAction];
    [alerter addAction:cancelAction];
    
    [self presentViewController:alerter animated:YES completion:^{

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

#pragma mark - Loading Data

-(void)findStopsForBusId:(NSString *)busId{
    //This method needs cleaning up
    
    if(!_busStops){
        _busStops = [NSMutableArray array];
    }
    _tappedBusId = busId;
    
    UIActivityIndicatorView * loadingIndicator = [SharedMethods createAndCenterLoadingIndicatorInView:self.view];
    [loadingIndicator startAnimating];
    
    NSMutableArray * stopIds = [NSMutableArray array];
    NSMutableDictionary<NSString *, BusStop *> * stopIdToBusStop = [NSMutableDictionary dictionary];
    
    NSMutableArray * destinationsLoc = [NSMutableArray array];
    
    for(BusStop * busStop in [[self.busData getNearbyStops] allValues]){
        
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
    double lat = [[LocationHandler sharedInstance].latitude doubleValue];
    double lng = [[LocationHandler sharedInstance].longitude doubleValue];
    CLLocation * from = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
    NSURLRequest * walkRequest = [APIHandler createWalkTimeRequestFromLocation:from ToLocations:destinationsLoc];
    
    [APIHandler parseJsonWithRequest:walkRequest CompletionBlock:^(NSDictionary * json) {
        if( ! ([[json objectForKey:@"rows"] count] == 0)){
         
            NSArray * walkTimes = [BusParser parseWalkTimes:json];
            for(int i = 0; i < [self.busStops count]; i++){
                [self.busStops objectAtIndex:i].walkTime = [walkTimes objectAtIndex:i];
            }
        }
        [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:stopIds Buses:[NSArray arrayWithObject:busId]] CompletionBlock:^(NSDictionary * json) {
            
            for(NSDictionary * data in [json objectForKey:@"data"]){
                BusStop * busStop = [stopIdToBusStop objectForKey:[data objectForKey:@"stop_id"]];
                NSArray * arrivalTimes = [BusParser parseArrivals:[data objectForKey:@"arrivals"]];
                busStop.arrivalTimes = arrivalTimes;
            }
            
            self.busStops = [[self.busStops sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{

                [loadingIndicator removeFromSuperview];
            });
        }];
    }];
}

@end

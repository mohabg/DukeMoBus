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

static NSString * cellIdentifier = @"BusStopsTableViewCell";

@interface BusStopsTableViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSArray<NSDictionary *> * busArrivalsPerStop;

@property (nonatomic, strong) NSMutableArray * stopIds;

@end

@implementation BusStopsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusStopsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellIdentifier];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    return [self.busArrivalsPerStop count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusStopsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    
    return cell;
}


-(void)findStopsForBusId:(NSString *)busId{
    if(!_stopIds){
        _stopIds = [NSMutableArray array];
    }
    
    for(BusStop * busStop in self.busData.busStops){
        
        for(NSString * busIdAtStop in busStop.busIDs){
            
            if([busIdAtStop isEqualToString:busId]){
                [_stopIds addObject:busStop.stopID];
            }
        }
    }
    
    [APIHandler parseJsonWithRequest:[APIHandler createArrivalTimeRequestForStops:_stopIds Buses:[NSArray arrayWithObject:busId]] CompletionBlock:^(NSDictionary * json) {
        NSLog(@"%@",[json objectForKey:@"data"]);
        NSArray<NSDictionary *> * data = [json objectForKey:@"data"];
        if(data){
            self.busArrivalsPerStop = data;
            [self.tableView reloadData];
        }
    }];
}
@end

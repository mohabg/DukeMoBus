//
//  FavoritesTableViewController.m
//  DukeMoBus
//
//  Created by Mohab Gabal on 8/26/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "FavoritesTableViewCell.h"
#import "FavoritesTableViewController.h"
#import "SharedMethods.h"

@interface FavoritesTableViewController ()

@property (nonatomic, strong) NSMutableArray * busTitles;

@property (nonatomic, strong) NSMutableArray * busIds;

@property (nonatomic, strong) NSMutableArray * stopTitles;

@property (nonatomic, strong) NSMutableArray * stopIds;

@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoritesTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FavoritesTableViewCell"];
    
    _busTitles = [NSMutableArray array];
    _stopTitles = [NSMutableArray array];
    _busIds = [NSMutableArray array];
    _stopIds = [NSMutableArray array];
    
    [self getFavoriteStops];
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

    return [_busTitles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoritesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FavoritesTableViewCell" forIndexPath:indexPath];
    
    cell.busNameLabel.text = [SharedMethods getUserFriendlyBusTitle:[_busTitles objectAtIndex:indexPath.row]];
    
    cell.stopNameLabel.text = [SharedMethods getUserFriendlyStopName: [_stopTitles objectAtIndex:indexPath.row]];
    
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.30]];
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.busData removeFavoriteBus:[_busIds objectAtIndex:row] ForStop:[_stopIds objectAtIndex:row]];
        
        [_busTitles removeObjectAtIndex:row];
        [_stopTitles removeObjectAtIndex:row];
        [_busIds removeObjectAtIndex:row];
        [_stopIds removeObjectAtIndex:row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

#pragma mark - Misc

-(void)getFavoriteStops{
    
    NSDictionary * favoriteBusesForStop = [self.busData getFavoriteBusesForStop];
    NSMutableDictionary * favoriteStopForBus = [NSMutableDictionary dictionary];
    
    //Store each bus to stop pair
    NSArray * busIds = [favoriteStopForBus allKeys];
    NSDictionary * stopIdToStopNames = [self.busData getStopIdToStopNames];

    for(NSString * stopId in [favoriteBusesForStop allKeys]){
        for(NSString * busId in [favoriteBusesForStop objectForKey:stopId]){
            
            [_busIds addObject:busId];
            [_stopIds addObject:stopId];
            
            [_busTitles addObject:[self.busData getBusNameForBusId:busId]];
            [_stopTitles addObject:[stopIdToStopNames objectForKey:stopId]];
        }
    }
    [self.tableView reloadData];
}

@end

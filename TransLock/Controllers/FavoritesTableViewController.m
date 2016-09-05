//
//  FavoritesTableViewController.m
//  DukeMoBus
//
//  Created by Mohab Gabal on 8/26/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "FavoritesTableViewCell.h"
#import "FavoritesTableViewController.h"
#import "BusRoute.h"
#import "SharedMethods.h"

@interface FavoritesTableViewController ()

@property (nonatomic, strong) NSMutableArray<BusRoute*> * favoriteRoutes;

@property (nonatomic, strong) NSMutableArray<BusStop*> * favoriteStops;

@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit"
//                                                                             style:UIBarButtonItemStylePlain
//                                                                            target:self
//                                                                            action:@selector(toggleEdit)];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoritesTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FavoritesTableViewCell"];
    
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

    return [_favoriteRoutes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoritesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FavoritesTableViewCell" forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    BusRoute * route = [_favoriteRoutes objectAtIndex:row];
    
    cell.busNameLabel.text = [SharedMethods getUserFriendlyBusTitle:route.routeName];
    
    cell.stopNameLabel.text = [SharedMethods getUserFriendlyStopName: [_favoriteStops objectAtIndex:row].stopName];
    
    [cell setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.30]];
    
    cell.showsReorderControl = YES;
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.busData removeFavoriteStopByIndex:row];
        [self.busData removeFavoriteRouteByIndex:row];
        
        [_favoriteRoutes removeObjectAtIndex:row];
        [_favoriteStops removeObjectAtIndex:row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    [SharedMethods swapFrom:sourceIndexPath.row To:destinationIndexPath.row InArray:_favoriteStops];
    [SharedMethods swapFrom:sourceIndexPath.row To:destinationIndexPath.row InArray:_favoriteRoutes];
    
    [self.busData swapFavoritesFrom:sourceIndexPath.row To:destinationIndexPath.row];
}

#pragma mark - Misc

-(void)getFavoriteStops{
    
    _favoriteRoutes = [[self.busData getFavoriteRoutes] mutableCopy];
    _favoriteStops = [[self.busData getFavoriteStops] mutableCopy];

    [self.tableView reloadData];
}

@end

//
//  BusesCollectionViewController.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "MPSkewedCell.h"
#import "MPSkewedParallaxLayout.h"
#import "BusStopsTableViewController.h"
#import "FavoritesTableViewController.h"
#import "BusesCollectionVC.h"
#import "BusParser.h"
#import "BusData.h"
#import "BusStop.h"
#import "APIHandler.h"
#import "SharedMethods.h"
#import "BusRoute.h"
#import "LocationHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface BusesCollectionVC ()

@property (strong, nonatomic) NSArray<BusRoute*> * activeBusRoutes;

@property (strong, nonatomic) NSArray * busNames;

@property (strong, nonatomic) NSString * tappedBusId;

@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;

@end


@implementation BusesCollectionVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.navigationController.hidesBarsOnSwipe = YES;
    
    if(![LocationHandler sharedInstance].longitude || ![LocationHandler sharedInstance].latitude){
        
        //Wait For Location Received Notification
        [_loadingIndicator startAnimating];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingIndicator = [SharedMethods createAndCenterLoadingIndicatorInView:self.view];
    
    MPSkewedParallaxLayout * layout = [[MPSkewedParallaxLayout alloc] init];
    layout.lineSpacing = 1;
    layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width, 150);
    
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[MPSkewedCell class] forCellWithReuseIdentifier:@"MPSkewedCell"];
    
    [self getActiveRoutes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNearbyBusStops:) name:@"Location Received" object:nil];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [(MPSkewedParallaxLayout *)self.collectionView.collectionViewLayout setItemSize:CGSizeMake(self.collectionView.bounds.size.width, 200)];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.activeBusRoutes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MPSkewedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MPSkewedCell" forIndexPath:indexPath];
    
    BusRoute * route = [self.activeBusRoutes objectAtIndex:indexPath.row];
    
    cell.text = route.routeName;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.tappedBusId = [self getBusIdForIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showBusStops" sender:self];
}


#pragma mark - Loading Data

-(void)loadNearbyBusStops:(NSNotification *)notification{
    
    NSString * lat = [notification.userInfo objectForKey:@"latitude"];
    NSString * lng = [notification.userInfo objectForKey:@"longitude"];

    [APIHandler parseJsonWithRequest:[APIHandler createBusStopRequestWithLatitude:lat Longitude:lng] CompletionBlock:^(NSDictionary * json) {
        
        //Load Bus Stops In Area
        NSArray * dataArr = [json objectForKey:@"data"];
        
        for(NSDictionary * data in dataArr){
            
            [self.busData addNearbyBusStop: [[BusStop alloc] initWithDictionary:data]];
        }
        //Load Bus Routes
        [self loadRoutesWithCompletion:^(NSDictionary * json) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.collectionView reloadData];
                
                [_loadingIndicator stopAnimating];
            });
        }];
    }];
}

-(void)loadRoutesWithCompletion:(void (^) (NSDictionary *))completion;{
    
    [BusParser loadRoutesIntoBusData:self.busData WithCompletion:^(NSDictionary * json){
        
        completion(json);
    }];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showBusStops"]){
        
        BusStopsTableViewController * stops = (BusStopsTableViewController *) [segue destinationViewController];
        stops.busData = self.busData;
        [stops findStopsForBusId:self.tappedBusId];
    }
}

#pragma mark - Misc

-(void)getActiveRoutes{
    NSMutableArray * activeRoutes = [NSMutableArray array];
    
    for(BusRoute * route in [self.busData getBusRoutes]){
        if(route.isActive){
            [activeRoutes addObject:route];
        }
    }
    self.activeBusRoutes = [NSArray arrayWithArray:activeRoutes];
}

-(NSString *)abbreviatedBusName:(NSString *)busName{
    NSMutableString * abbreviatedName = [[NSMutableString alloc] init];
    
    for(int i = 0; i < busName.length; i++){
        [abbreviatedName appendFormat:@"%c", [busName characterAtIndex:i]];
        
        if([busName characterAtIndex:i] == ':'){
            break;
        }
    }
    return abbreviatedName;
}

-(NSString *)getBusIdForIndex:(NSInteger)index{
    NSString * selectedBusName = [self.busNames objectAtIndex:index];
    NSString * selectedBusId;
    
    for(NSString * busId in [self.busData getIdToBusNames]){
        NSString * busName = [self.busData getBusNameForBusId:busId];
        
        if([busName isEqualToString:selectedBusName]){
            selectedBusId = busId;
        }
    }
    return selectedBusId;
}

-(NSArray *)busNames{
    
    NSArray * unsortedBuses = [[self.busData getIdToBusNames] allValues];
    return [unsortedBuses sortedArrayUsingSelector:@selector(compare:)];
}

@end

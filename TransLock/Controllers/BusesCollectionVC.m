//
//  BusesCollectionViewController.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "MPSkewedCell.h"
#import "MPSkewedParallaxLayout.h"
#import <AMScrollingNavbar/AMScrollingNavbar-Swift.h>
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

@property (strong, nonatomic) NSString * tappedBusId;

@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;

@property (assign, nonatomic) BOOL askedForNearbyStops;

@end


@implementation BusesCollectionVC


#pragma mark - Setup

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //self.navigationController.hidesBarsOnSwipe = YES;
    
    [(ScrollingNavigationController *)self.navigationController followScrollView:self.collectionView delay:50.0f];

    
    if(![LocationHandler sharedInstance].longitude || ![LocationHandler sharedInstance].latitude){
        
        //Wait For Location Received Notification
        [_loadingIndicator startAnimating];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if([self.navigationController isKindOfClass:[ScrollingNavigationController class]]){
        ScrollingNavigationController * scrollNav = (ScrollingNavigationController *)self.navigationController;
       // [scrollNav showNavbarWithAnimated:YES];
        [scrollNav stopFollowingScrollView];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _askedForNearbyStops = NO;
    
    self.loadingIndicator = [SharedMethods createAndCenterLoadingIndicatorInView:self.view];
    
    MPSkewedParallaxLayout * layout = [[MPSkewedParallaxLayout alloc] init];
    layout.lineSpacing = 1;
    layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width, 150);
    
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[MPSkewedCell class] forCellWithReuseIdentifier:@"MPSkewedCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNearbyBusStops:) name:@"Location Received" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationAccess:) name:@"Need Location Access" object:nil];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        self.navigationController.hidesBarsOnSwipe = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        self.navigationController.hidesBarsOnSwipe = YES;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.tappedBusId = [self.activeBusRoutes objectAtIndex:indexPath.row].routeId;
    
    [self performSegueWithIdentifier:@"showBusStops" sender:self];
}


#pragma mark - Loading Data

-(void)loadNearbyBusStops:(NSNotification *)notification{
    if(!_askedForNearbyStops){
        _askedForNearbyStops = YES;
        
        //Load Bus Routes
        [self loadRoutesWithCompletion:^(NSDictionary * json) {
            
            self.activeBusRoutes = [self.busData getActiveBusRoutes];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self reloadData];
                
                [_loadingIndicator stopAnimating];
            });
            NSInteger initialDistanceFilter = 450; //meters
            
            NSMutableArray * activeRouteIds = [NSMutableArray array];
            for(BusRoute * activeRoute in self.activeBusRoutes){
                
                [activeRouteIds addObject:activeRoute.routeId];
            }
            
            void (^loadStopsBlock)(NSArray *, NSDictionary *) = ^void(NSArray * routeIds, NSDictionary * json){

                NSArray * dataArr = [json objectForKey:@"data"];
                
                for(NSDictionary * data in dataArr){
                    NSArray * routes = [data objectForKey:@"routes"];
                    for(NSString * routeId in routes){
                        
                        if([routeIds containsObject:routeId]){
                            
                            [self.busData addNearbyBusStop:[[BusStop alloc] initWithDictionary:data] ForRouteId:routeId];
                        }
                    }
                }
            };
            
            [self askForNearbyStopsWithDistanceFilter:initialDistanceFilter WithCompletion:^(NSDictionary * json) {
                
                loadStopsBlock(activeRouteIds, json);
                
                NSMutableArray * farAwayRouteIds = [NSMutableArray array];
                
                for(BusRoute * activeRoute in self.activeBusRoutes){
                    
                    NSString * routeId = activeRoute.routeId;
                    NSArray<BusStop*> * stopsForRoute = [self.busData getBusStopsForRouteId:routeId];
                    
                    if([stopsForRoute count] == 0){
                        
                        [farAwayRouteIds addObject:activeRoute.routeId];
                    }
                }
                if(farAwayRouteIds){
                    
                    [self askForNearbyStopsWithDistanceFilter:initialDistanceFilter * 2 WithCompletion:^(NSDictionary * json) {
                        
                        loadStopsBlock(farAwayRouteIds, json);
                    }];
                }
            }];
        }];
    }
}

-(void)askForNearbyStopsWithDistanceFilter:(NSInteger)distance WithCompletion:(void (^) (NSDictionary *))completion{
    
    [APIHandler parseJsonWithRequest:[APIHandler createBusStopRequestWithDistance:distance FromLatitude:[LocationHandler sharedInstance].latitude Longitude:[LocationHandler sharedInstance].longitude] CompletionBlock:^(NSDictionary * json) {
        
        completion(json);
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

-(void)requestLocationAccess:(NSNotification *)notification{
    
    UIAlertController * alerter = [UIAlertController alertControllerWithTitle:@"Need Location Access" message:@"Without your location we can't find bus stops near you." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alerter addAction:cancelAction];
    [alerter addAction:settingsAction];
    
    [self presentViewController:alerter animated:YES completion:nil];
}

-(NSString *)abbreviatedBusName:(NSString *)busName{
    NSMutableString * abbreviatedName = [[NSMutableString alloc] init];
    
    for(int i = 0; i < busName.length; i++){
        [abbreviatedName appendFormat:@"%c", [busName characterAtIndex:i]];
        
        if([busName characterAtIndex:i] == ':' || [busName characterAtIndex:i] == ' '){
            break;
        }
    }
    return abbreviatedName;
}

-(void)reloadData{
    
    NSArray<BusRoute*> * activeRoutes = [self.busData getActiveBusRoutes];
    //Sort By Name
    NSSortDescriptor * routeSorter = [[NSSortDescriptor alloc] initWithKey:@"routeName" ascending:YES];
    self.activeBusRoutes = [activeRoutes sortedArrayUsingDescriptors:[NSArray arrayWithObject:routeSorter]];
    
    self.activeBusRoutes = [self.busData getBusRoutes];
    
    [self.collectionView reloadData];
}

@end

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
#import "BusesCollectionVC.h"
#import "BusParser.h"
#import "BusData.h"
#import "BusStop.h"
#import "APIHandler.h"
#import "SharedMethods.h"
#import <QuartzCore/QuartzCore.h>

@interface BusesCollectionVC ()

@property (strong, nonatomic) NSArray * busIds;

@property (strong, nonatomic) NSString * tappedBusId;

@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;

@end


@implementation BusesCollectionVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Load list of available routes
    
    [_loadingIndicator startAnimating];
    
    [BusParser loadRoutesIntoBusData:self.busData WithCompletion:^(NSDictionary * json){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.collectionView reloadData];
            
            if(self.busData.userLatitude && self.busData.userLongitude){
                //Location Also Received -- Stop Loading Indicator
                
                [_loadingIndicator stopAnimating];
            }
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingIndicator = [SharedMethods createAndCenterLoadingIndicatorInView:self.view];
    
    self.navigationController.hidesBarsOnSwipe = YES;
    
    MPSkewedParallaxLayout * layout = [[MPSkewedParallaxLayout alloc] init];
    layout.lineSpacing = 1;
    layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width, 150);
    
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.collectionView registerClass:[MPSkewedCell class] forCellWithReuseIdentifier:@"MPSkewedCell"];
    
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
    
    return [self.busIds count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MPSkewedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MPSkewedCell" forIndexPath:indexPath];
    
    NSString * busId = [self.busIds objectAtIndex:indexPath.row];
    
    cell.text = [self.busData getBusNameForBusId:busId];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.tappedBusId = [self.busIds objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showBusStops" sender:self];
}


#pragma mark - Loading Data

-(void)loadNearbyBusStops:(NSNotification *)notification{
    
    NSString * lat = [notification.userInfo objectForKey:@"latitude"];
    NSString * lng = [notification.userInfo objectForKey:@"longitude"];
    
    self.busData.userLatitude = lat;
    self.busData.userLongitude = lng;
        
    [APIHandler parseJsonWithRequest:[APIHandler createBusStopRequestWithLatitude:lat Longitude:lng] CompletionBlock:^(NSDictionary * json) {
        
        //Load Bus Stops In Area
        NSArray * dataArr = [json objectForKey:@"data"];
        
        if(dataArr){
            
            [self.busData clearNearbyBusStops];
            
            for(NSDictionary * data in dataArr){
                
                BusStop * busStop = [[BusStop alloc] initWithDictionary:data];
                
                [self.busData addNearbyBusStop:busStop];
            }
            
            if([[self.busData getIdToBusNames] count] > 0){
                //Bus Routes Already Loaded -- Stop Loading Indicator
                
                [_loadingIndicator stopAnimating];
            }
        }
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

-(NSArray *)busIds{
    
    return [[self.busData getIdToBusNames] allKeys];
}

@end

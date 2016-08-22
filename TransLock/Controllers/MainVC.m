//
//  MainVC.m
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "MainVC.h"
#import "BusesCollectionVC.h"
#import "BusParser.h"
#import "APIHandler.h"
#import "LocationHandler.h"
#import "SharedMethods.h"

@interface MainVC ()

@property (strong, nonatomic) IBOutlet UILabel * jokeLabel;

@property (strong, nonatomic) LocationHandler * locationHandler;

@property (assign, nonatomic) BOOL loadedBusStops;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.loadedBusStops = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNearbyBusStops:) name:@"Location Received" object:nil];
}

#pragma mark - Loading Data

-(void)loadNearbyBusStops:(NSNotification *)notification{
    if(!self.loadedBusStops){
        //CLLocationManager delegate didUpdateLocations gets called twice for one request sometimes
        
        self.loadedBusStops = YES;
        
        self.busData.userLatitude = self.locationHandler.latitude;
        self.busData.userLongitude = self.locationHandler.longitude;
        NSString * lat = self.locationHandler.latitude;
        NSString * lng = self.locationHandler.longitude;
        
        lat = @"36.004162";
        lng = @"-78.931327";
        
        //WARNING: CASES MAY OCCUR WHERE USER CHOOSES A BUS BEFORE STOPS ARE LOADED
        
        [APIHandler parseJsonWithRequest:[APIHandler createBusStopRequestWithLatitude:lat Longitude:lng] CompletionBlock:^(NSDictionary * json) {
            
            //Load Bus Stops In Area
            NSArray * dataArr = [json objectForKey:@"data"];
            for(int i = 0; i < [dataArr count]; i++){
                
                BusStop * busStop = [[BusStop alloc] init];
                [busStop loadFromDictionary: [dataArr objectAtIndex:i] ];
                
                [self.busData addNearbyBusStop:busStop];
            }
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"embedCollection"]){
        BusesCollectionVC * busCollectionController = (BusesCollectionVC *) [segue destinationViewController];
        
        busCollectionController.busData = self.busData;
    }
}
@end

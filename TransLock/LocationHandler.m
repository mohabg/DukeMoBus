//
//  LocationHandler.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "LocationHandler.h"
#import "APIHandler.h"

@interface LocationHandler()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) dispatch_group_t group;

@end

@implementation LocationHandler
-(instancetype)init{
    self = [super init];
    if(self){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = 50.0f;
        self.group = dispatch_group_create();
    }
    return self;
}

-(void)start{
    BOOL isAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
                                                        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    
    
    if (isAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
   
    [manager stopUpdatingLocation];
    
    self.longitude = [NSString stringWithFormat:@"%f", locations.firstObject.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f", locations.firstObject.coordinate.latitude];
    
    NSString * lat = @"36.005144";
    NSString * lng = @"-78.944213";
    
    //WARNING: CASES MAY OCCUR WHERE USER CHOOSES A BUS BEFORE STOPS ARE LOADED
    
    [APIHandler parseJsonWithRequest:[APIHandler createBusStopRequestWithLatitude:lat Longitude:lng] CompletionBlock:^(NSDictionary * json) {
        
        //Load Bus Stops In Area
        NSArray * dataArr = [json objectForKey:@"data"];
        for(int i = 0; i < [dataArr count]; i++){
            
            BusStop * busStop = [[BusStop alloc] init];
            [busStop loadFromDictionary: [dataArr objectAtIndex:i] ];
            
            [APIHandler parseJsonWithRequest:[APIHandler createWalkTimeRequestWithLatitude:lat Longitude:lng BusStop:busStop]
                             CompletionBlock:^(NSDictionary * json){
                           
                           [busStop loadWalkTimes:json];
                       }];
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    //TODO: SHOW RETRY OPTION TO USER
    
    NSLog(@"Location failed with error: %@", [error localizedDescription]);
}
@end

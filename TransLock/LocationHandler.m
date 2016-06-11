//
//  LocationHandler.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "LocationHandler.h"

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
    
    // dispatch_group_enter(self.group);
    NSLog(@"Location Waiting");
    if (isAuthorized) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self.locationManager requestWhenInUseAuthorization];
    }
    //dispatch_group_wait(self.group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
   
    [manager stopUpdatingLocation];
    self.longitude = [NSString stringWithFormat:@"%f", locations.firstObject.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f", locations.firstObject.coordinate.latitude];
   // dispatch_group_leave(self.group);
    NSLog(@"Location Done");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Location Received" object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        //[manager startUpdatingLocation];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    @throw [NSException exceptionWithName:@"Location Fetch Error" reason:[error localizedDescription] userInfo:nil];
}
@end

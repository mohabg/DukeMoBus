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

static LocationHandler * locationHandler;

@implementation LocationHandler

#pragma mark - Singleton Methods

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        locationHandler = [[LocationHandler alloc] initPrivate];
    });
    
    return locationHandler;
}

-(instancetype)initPrivate{
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

-(instancetype)init{
    
    @throw [NSException exceptionWithName:@"Should not call init" reason:@"Singleton, Use 'sharedInstance'" userInfo:nil];
}

-(void)startGettingLocation{
    BOOL isAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
                                                        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    
    
    if (isAuthorized) {
        [self.locationManager requestLocation];
    }
    else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark - Location Manager Delegate


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
   
    [manager stopUpdatingLocation];
    
    self.longitude = [NSString stringWithFormat:@"%f", locations.firstObject.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f", locations.firstObject.coordinate.latitude];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Location Received" object:nil];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    //TODO: SHOW RETRY OPTION TO USER
    
    NSLog(@"Location failed with error: %@", [error localizedDescription]);
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
   if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedAlways ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
       
       [manager requestLocation];
       }
   else{
       NSLog(@"LOCATION NOT ALLOWED");
   }
}
@end

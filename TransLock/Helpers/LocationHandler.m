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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 50.0f;
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
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
   
   // [self.locationManager stopUpdatingLocation];
    
    self.longitude = [NSString stringWithFormat:@"%f", locations.lastObject.coordinate.longitude];
    self.latitude = [NSString stringWithFormat:@"%f", locations.lastObject.coordinate.latitude];
    
    self.latitude = @"36.00410964";
    self.longitude = @"-78.93139637";
    
    NSLog(@"LOCATION RECEIVED -- %@, %@", self.latitude, self.longitude);
    
   // NSLog(@"Locations Array -- %@", locations);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Location Received" object:nil userInfo:@{@"latitude" : self.latitude, @"longitude" : self.longitude}];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    //TODO: SHOW RETRY OPTION TO USER
    
    NSLog(@"Location failed with error: %@", [error localizedDescription]);
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
   if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedAlways ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
       
       NSLog(@"LOCATION ACCEPTED -- REQUESTING");
       
       [self.locationManager startUpdatingLocation];
       }
   else{
       NSLog(@"LOCATION NOT ALLOWED");
       
    //   UIAlertController * alerter = [UIAlertController alertControllerWithTitle:@"Need Location Access" message:@"Without your location we can't find bus stops near you." preferredStyle:UIAlertControllerStyleAlert];
  //     UIAlertAction * mapsAction = [UIAlertAction actionWithTitle:@"Directions" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
         //  [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @""]];
      // }];
   }
}
@end

//
//  LocationHandler.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusesCollectionVC.h"

@import CoreLocation;

@interface LocationHandler : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * latitude;

-(void)startGettingLocation;

+(instancetype)sharedInstance;

@end

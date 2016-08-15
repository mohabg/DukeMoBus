//
//  BusData.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusVehicle.h"
#import "BusStop.h"

@interface BusData : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray * allowedBusIDs; 
@property (nonatomic, strong) NSMutableArray<BusStop *> * busStops;
@property (nonatomic, strong) NSMutableDictionary * idToBusNames;
@property (nonatomic, strong) NSMutableDictionary * vehiclesForStopID;

-(void)loadArrivalTimes:(NSDictionary *)dictionary ForStopID:(NSString *)stopID;
-(BOOL)allowedBusIDsContainsBusID:(NSString *)busID;

@end

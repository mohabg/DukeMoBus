//
//  BusData.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStop.h"

@interface BusData : NSObject 

@property (nonatomic, strong) NSString * userLatitude;
@property (nonatomic, strong) NSString * userLongitude;

-(void)addFavoriteStop:(BusStop *)favoriteStop;

-(NSArray<BusStop*> *)getFavoriteStops;
-(NSArray<BusStop*> *)getNearbyStops;
-(NSDictionary *)getIdToBusNames;

-(void)setBusName:(NSString *)busName ForBusId:(NSString *)busId;
-(NSString *)getBusNameForBusId:(NSString *)busId;

-(void)addNearbyBusStop:(BusStop *)busStop;

@end

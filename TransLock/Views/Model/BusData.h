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

//
-(NSDictionary<NSString*, NSArray*> *)getFavoriteStops;
-(NSArray<BusStop*> *)getNearbyStops;
-(NSDictionary *)getIdToBusNames;

-(void)addFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop;
-(void)removeFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop;

-(void)setBusName:(NSString *)busName ForBusId:(NSString *)busId;
-(NSString *)getBusNameForBusId:(NSString *)busId;

-(void)clearNearbyBusStops;
-(void)addNearbyBusStop:(BusStop *)busStop;

-(NSDictionary *)getStopIdToStopNames;

@end

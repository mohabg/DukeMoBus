//
//  BusData.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStop.h"
#import "BusRoute.h"

@interface BusData : NSObject

-(NSDictionary<NSString*, NSArray*> *)getFavoriteBusesForStop;

-(NSDictionary<NSString*, BusStop*> *)getNearbyStops;

-(NSDictionary *)getIdToBusNames;

-(void)addFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop;
-(void)removeFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop;

-(void)addBusRoute:(BusRoute *)busRoute;
-(NSArray<BusRoute*> *)getBusRoutes;
-(BusRoute *)getBusRouteForRouteId:(NSString *)routeId;

//-(void)setBusName:(NSString *)busName ForBusId:(NSString *)busId;
//-(NSString *)getBusNameForBusId:(NSString *)busId;

-(void)addNearbyBusStop:(BusStop *)busStop;

-(NSDictionary *)getStopIdToStopNames;

@end

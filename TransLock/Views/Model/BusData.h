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

//-(NSDictionary<NSString*, NSArray<BusRoute*> *> *)getFavoriteRoutesForStop;

-(NSDictionary *)getIdToBusNames;

//-(void)addFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop;
//-(void)removeFavoriteBus:(BusRoute *)bus ForStop:(NSString *)busStop;

-(void)addBusRoute:(BusRoute *)busRoute;

-(NSArray<BusRoute*> *)getBusRoutes;
-(NSArray<BusRoute*> *)getActiveBusRoutes;

-(BusRoute *)getBusRouteForRouteId:(NSString *)routeId;

-(NSArray<BusStop*> *)getBusStopsForRouteId:(NSString *)routeId;

-(BusStop *)getBusStopForStopId:(NSString *)stopId;

-(void)addNearbyBusStop:(BusStop *)busStop ForRouteId:(NSString *)routeId;

-(void)addFavoriteRouteById:(NSString *)routeId;

-(void)addFavoriteStopById:(NSString *)stopId;

-(void)removeFavoriteRouteByIndex:(NSInteger)index;

-(void)removeFavoriteStopByIndex:(NSInteger)index;

-(NSArray<BusRoute*> *)getFavoriteRoutes;

-(NSArray<BusStop*> *)getFavoriteStops;

-(void)swapFavoritesFrom:(NSInteger)fromIndex To:(NSInteger)toIndex;

@end

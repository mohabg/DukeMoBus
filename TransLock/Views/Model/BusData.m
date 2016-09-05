//
//  BusData.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusData.h"
#import "SharedMethods.h"

@interface BusData ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSArray<BusStop*> *> * busStopsForRouteId;
//
//@property (nonatomic, strong) NSMutableDictionary<NSString*, NSArray<BusRoute*> *> * favoriteRoutesForStop;

@property (nonatomic, strong) NSMutableArray<BusRoute*> * favoriteRoutes;

@property (nonatomic, strong) NSMutableArray<BusStop*> * favoriteStops;

@property (nonatomic, strong) NSMutableDictionary<NSString *, BusStop *> * idToBusStop;

@property (nonatomic, strong) NSMutableDictionary * idToBusNames;

@property (nonatomic, strong) NSMutableArray * busRoutes;

@end


@implementation BusData

-(instancetype)init{
    self = [super init];
    if(self){
        self.busStopsForRouteId = [NSMutableDictionary dictionary];
        self.idToBusNames = [NSMutableDictionary dictionary];
        self.idToBusStop = [NSMutableDictionary dictionary];
        self.busRoutes = [NSMutableArray array];
        
        self.favoriteStops = [[SharedMethods unarchiveFavStops] mutableCopy];
        self.favoriteRoutes = [[SharedMethods unarchiveFavRoutes] mutableCopy];
        
//        NSDictionary * favoritesDict = [customDefaults dictionaryForKey:@"favorites"];
//        
//        for(NSString * stopId in [favoritesDict allKeys]){
//            NSMutableArray * favRoutes = [NSMutableArray array];
//            
//            for(NSData * favRoutesData in [favoritesDict objectForKey:stopId]){
//                BusRoute * favRoute = [NSKeyedUnarchiver unarchiveObjectWithData:favRoutesData];
//                [favRoutes addObject:favRoute];
//            }
//            [favRoutesForStop setObject:favRoutes forKey:stopId];
//        }
    //   self.favoriteRoutesForStop = favRoutesForStop;
    }
    return self;
}

#pragma mark - Set/Add

-(void)addFavoriteRouteById:(NSString *)routeId{
    
    [_favoriteRoutes addObject:[self getBusRouteForRouteId:routeId]];
}

-(void)addFavoriteStopById:(NSString *)stopId{
    
    [_favoriteStops addObject:[self getBusStopForStopId:stopId]];
}

//-(void)addFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop{
//    NSMutableArray * favoriteRoutes = [[_favoriteRoutesForStop objectForKey:busStop] mutableCopy];
//    
//    if(!favoriteRoutes){
//        favoriteRoutes = [NSMutableArray array];
//    }
//    [favoriteRoutes addObject:[self getBusRouteForRouteId:busId]];
//    
//    [_favoriteRoutesForStop setObject:favoriteRoutes forKey:busStop];
//}

-(void)addNearbyBusStop:(BusStop *)busStop ForRouteId:(NSString *)routeId{
   
    NSMutableArray * stops = [[self.busStopsForRouteId objectForKey:routeId] mutableCopy];
    if(!stops){
        stops = [NSMutableArray array];
    }
                              
    [stops addObject:busStop];
    
    [self.busStopsForRouteId setObject:stops forKey:routeId];
    
    [self.idToBusStop setObject:busStop forKey:busStop.stopID];
}

-(void)addBusRoute:(BusRoute *)busRoute{
    
    [_busRoutes addObject:busRoute];
}

#pragma mark - Get/Remove
//
//-(NSDictionary<NSString *,NSArray<BusRoute*> *> *)getFavoriteRoutesForStop{
//
//    return [NSDictionary dictionaryWithDictionary:_favoriteRoutesForStop];
//}

-(NSDictionary *)getIdToBusNames{
    
    return [NSDictionary dictionaryWithDictionary:self.idToBusNames];
}

-(NSArray *)getBusRoutes{
    
    return _busRoutes;
}

-(NSArray<BusRoute *> *)getActiveBusRoutes{
    NSMutableArray * activeRoutes = [NSMutableArray array];
    
    for(BusRoute * route in _busRoutes){
        if(route.isActive){
            [activeRoutes addObject:route];
        }
    }
    return activeRoutes;
}

-(BusRoute *)getBusRouteForRouteId:(NSString *)routeId{
    
    for(BusRoute * route in _busRoutes){
        
        if([route.routeId isEqualToString:routeId]){
            return route;
        }
    }
    return nil;
}

-(BusStop *)getBusStopForStopId:(NSString *)stopId{
    
    return [_idToBusStop objectForKey:stopId];
}

-(NSArray<BusStop *> *)getBusStopsForRouteId:(NSString *)routeId{
    
    return [self.busStopsForRouteId objectForKey:routeId];
}

-(void)removeFavoriteRouteByIndex:(NSInteger)index{
    
    [_favoriteRoutes removeObjectAtIndex:index];
}

-(void)removeFavoriteStopByIndex:(NSInteger)index{
    
    [_favoriteStops removeObjectAtIndex:index];
}

-(NSArray<BusStop *> *)getFavoriteStops{
    
    return _favoriteStops;
}

-(NSArray<BusRoute *> *)getFavoriteRoutes{
    
    return _favoriteRoutes;
}

#pragma mark - Misc

-(void)swapFavoritesFrom:(NSInteger)fromIndex To:(NSInteger)toIndex{
    
    [SharedMethods swapFrom:fromIndex To:toIndex InArray:_favoriteStops];
    [SharedMethods swapFrom:fromIndex To:toIndex InArray:_favoriteRoutes];
}

@end

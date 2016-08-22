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

@property (nonatomic, strong) NSMutableArray<BusStop*> * nearbyBusStops;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray*> * favoriteBusesForStop;
@property (nonatomic, strong) NSMutableDictionary * idToBusNames;

@end


@implementation BusData

-(instancetype)init{
    self = [super init];
    if(self){
        self.nearbyBusStops = [[NSMutableArray alloc] init];
        self.idToBusNames = [[NSMutableDictionary alloc] init];
        self.favoriteBusesForStop = [NSKeyedUnarchiver unarchiveObjectWithFile:[SharedMethods getArchivePathUsingString:@"favorites.archive"]];
        
        if(!self.favoriteBusesForStop){
            self.favoriteBusesForStop = [NSMutableDictionary dictionary];
        }
    }
    return self;
}
-(void)addFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop{
    
    NSMutableArray * favoriteBusIds = [_favoriteBusesForStop objectForKey:busStop];
    if(!favoriteBusIds){
        favoriteBusIds = [NSMutableArray array];
    }
    [favoriteBusIds addObject:busId];
    
    [_favoriteBusesForStop setObject:favoriteBusIds forKey:busStop];
}

-(void)removeFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop{
    
    NSMutableArray * favoriteBusIds = [_favoriteBusesForStop objectForKey:busStop];
    if(!favoriteBusIds){
        return;
    }
    [favoriteBusIds removeObject:busId];
 
    [_favoriteBusesForStop setObject:favoriteBusIds forKey:busStop];
}

-(void)setBusName:(NSString *)busName ForBusId:(NSString *)busId{
    
    [self.idToBusNames setObject:busName forKey:busId];
}

-(void)clearNearbyBusStops{
   
    self.nearbyBusStops = [NSMutableArray array];
}

-(void)addNearbyBusStop:(BusStop *)busStop{
    
    [self.nearbyBusStops addObject:busStop];
}

-(NSString *)getBusNameForBusId:(NSString *)busId{
    
    return [self.idToBusNames objectForKey:busId];
}

#pragma mark - Getters

-(NSDictionary<NSString *,NSArray *> *)getFavoriteStops{

    return [NSDictionary dictionaryWithDictionary:_favoriteBusesForStop];
}

-(NSArray<BusStop *> *)getNearbyStops{
    
    return [NSArray arrayWithArray:self.nearbyBusStops];
}

-(NSDictionary *)getIdToBusNames{
    
    return [NSDictionary dictionaryWithDictionary:self.idToBusNames];
}

-(NSDictionary *)getStopIdToStopNames{
    
    NSMutableDictionary * stopIdToNames = [NSMutableDictionary dictionary];
    
    for(BusStop * stop in self.nearbyBusStops){
        
        [stopIdToNames setObject:stop.stopName forKey:stop.stopID];
    }
    
    return stopIdToNames;
}
@end

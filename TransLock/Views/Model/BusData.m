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

@property (nonatomic, strong) NSMutableDictionary<NSString*, BusStop*> * nearbyBusStops;

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray*> * favoriteBusesForStop;

@property (nonatomic, strong) NSMutableDictionary * idToBusNames;

@end


@implementation BusData

-(instancetype)init{
    self = [super init];
    if(self){
        self.nearbyBusStops = [NSMutableDictionary dictionary];
        self.idToBusNames = [NSMutableDictionary dictionary];
        
        NSUserDefaults * customDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.DukeMoBus"];
        self.favoriteBusesForStop = [[customDefaults objectForKey:@"favoriteStops"] mutableCopy];
        
        if(!self.favoriteBusesForStop){
            self.favoriteBusesForStop = [NSMutableDictionary dictionary];
        }
    }
    return self;
}
-(void)addFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop{
    
    NSMutableArray * favoriteBusIds = [[_favoriteBusesForStop objectForKey:busStop] mutableCopy];
    if(!favoriteBusIds){
        favoriteBusIds = [NSMutableArray array];
    }
    [favoriteBusIds addObject:busId];
    
    [_favoriteBusesForStop setObject:favoriteBusIds forKey:busStop];
}

-(void)removeFavoriteBus:(NSString *)busId ForStop:(NSString *)busStop{
    
    NSMutableArray * favoriteBusIds = [[_favoriteBusesForStop objectForKey:busStop] mutableCopy];
    if(!favoriteBusIds){
        return;
    }
    for(NSString * favoriteId in favoriteBusIds){
        if([favoriteId isEqualToString:busId]){
            [favoriteBusIds removeObject:favoriteId];
        }
    }
    [_favoriteBusesForStop setObject:favoriteBusIds forKey:busStop];
}

-(void)setBusName:(NSString *)busName ForBusId:(NSString *)busId{
    
    [self.idToBusNames setObject:busName forKey:busId];
}

-(void)addNearbyBusStop:(BusStop *)busStop{

    [self.nearbyBusStops setObject:busStop forKey:busStop.stopID];
}

-(NSString *)getBusNameForBusId:(NSString *)busId{
    
    return [self.idToBusNames objectForKey:busId];
}

#pragma mark - Getters

-(NSDictionary<NSString *,NSArray *> *)getFavoriteBusesForStop{

    return [NSDictionary dictionaryWithDictionary:_favoriteBusesForStop];
}

-(NSDictionary *)getNearbyStops{
    
    return [NSDictionary dictionaryWithDictionary:self.nearbyBusStops];
}

-(NSDictionary *)getIdToBusNames{
    
    return [NSDictionary dictionaryWithDictionary:self.idToBusNames];
}

-(NSDictionary *)getStopIdToStopNames{
    
    NSMutableDictionary * stopIdToNames = [NSMutableDictionary dictionary];
    
    for(BusStop * stop in [self.nearbyBusStops allValues]){

        [stopIdToNames setObject:stop.stopName forKey:stop.stopID];
    }
    
    return stopIdToNames;
}
@end

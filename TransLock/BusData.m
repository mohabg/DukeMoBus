//
//  BusData.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusData.h"

@interface BusData ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<BusStop*>*> * busStopsForStopId;

@end


@implementation BusData

-(instancetype)init{
    self = [super init];
    if(self){
        self.nearbyBusStops = [[NSMutableArray alloc] init];
        self.idToBusNames = [[NSMutableDictionary alloc] init];
        self.vehiclesForStopID = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.idToBusNames = [[NSMutableDictionary alloc] init];
        self.vehiclesForStopID = [[NSMutableDictionary alloc] init];
        self.nearbyBusStops = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.idToBusNames forKey:@"idToBusNames"];
}


-(void)loadArrivalTimes:(NSDictionary *)dictionary ForStopID:(NSString *)stopID{
    NSArray * arrivals;
    if([[dictionary objectForKey:@"data"] count] >= 1){
        arrivals = [[[dictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"arrivals"];
    }
    NSMutableArray * vehicles = [[NSMutableArray alloc] init];
    for(NSDictionary * dic in arrivals){
        NSString * busID = [dic objectForKey:@"route_id"];

        NSString * arrivalTime = [dic objectForKey:@"arrival_at"];
        
        BusVehicle * bus = [[BusVehicle alloc] init];
        bus.busID = busID;
        bus.busName = [self.idToBusNames objectForKey:busID];
        bus.arrivalTimeString = arrivalTime;
        
        [vehicles addObject:bus];
        [self.vehiclesForStopID setObject:vehicles forKey:stopID];
    }
}

-(NSArray<BusStop*> *)nearbyBusStopsForStopId:(NSString *)stopId{
    
    return [_busStopsForStopId objectForKey:stopId];
}

-(void)setBusStops:(NSArray<BusStop*> *)busStops ForStopId:(NSString *)stopId{
    
    [_busStopsForStopId setObject:busStops forKey:stopId];
}

@end

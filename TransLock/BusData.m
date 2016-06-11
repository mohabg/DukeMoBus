//
//  BusData.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusData.h"

@implementation BusData
-(instancetype)init{
    self = [super init];
    if(self){
        self.busStops = [[NSMutableArray alloc] init];
        self.allowedBusIDs = [[NSMutableArray alloc] init];
        self.idToBusNames = [[NSMutableDictionary alloc] init];
        self.vehiclesForStopID = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.idToBusNames = [aDecoder decodeObjectForKey:@"idToBusNames"];
        self.allowedBusIDs = [aDecoder decodeObjectForKey:@"allowedBusIDs"];
        self.vehiclesForStopID = [[NSMutableDictionary alloc] init];
        self.busStops = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.idToBusNames forKey:@"idToBusNames"];
    [aCoder encodeObject:self.allowedBusIDs forKey:@"allowedBusIDs"];
}

-(void)loadArrivalTimes:(NSDictionary *)dictionary ForStopID:(NSString *)stopID{
    NSArray * arrivals;
    if([[dictionary objectForKey:@"data"] count] >= 1){
        arrivals = [[[dictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"arrivals"];
    }
    if([arrivals count] == 0){
        
    }
    for(NSDictionary * dic in arrivals){
        NSString * busID = [dic objectForKey:@"route_id"];
        NSString * arrivalTime = [dic objectForKey:@"arrival_at"];
        BusVehicle * bus = [[BusVehicle alloc] init];
        bus.busID = busID;
        bus.busName = [self.idToBusNames objectForKey:busID];
        bus.arrivalTimeString = arrivalTime;
        NSMutableArray * vehicles = [self.vehiclesForStopID objectForKey:stopID];
        if(!vehicles){
            vehicles = [[NSMutableArray alloc] init];
        }
        [vehicles addObject:bus];
        [self.vehiclesForStopID setObject:vehicles forKey:stopID];
    }
}

@end

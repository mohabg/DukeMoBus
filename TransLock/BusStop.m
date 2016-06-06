//
//  BusStop.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusStop.h"

@implementation BusStop

-(NSString *)getUserFriendlyName{
    NSMutableString * nameWithoutParantheses = [[NSMutableString alloc] init];
    for(int i = 0; i < _name.length; i++){
        if([_name characterAtIndex:i] == '('){
            break;
        }
        [nameWithoutParantheses appendFormat:@"%c", [_name characterAtIndex:i]];
    }
    return nameWithoutParantheses;
}

-(void)loadFromDictionary:(NSDictionary *)dictionary{
    self.name = [dictionary objectForKey:@"name"];
    self.busIDs = [dictionary objectForKey:@"routes"];
    self.stopID = [dictionary objectForKey:@"stop_id"];
    NSDictionary * location = [dictionary objectForKey:@"location"];
    self.longitude = [location objectForKey:@"lng"];
    self.latitude = [location objectForKey:@"lat"];
}

-(void)loadArrivalTimes:(NSDictionary *)dictionary{
    self.arrivalTimes = [[NSMutableDictionary alloc] init];
    NSArray * arrivals;
    if([[dictionary objectForKey:@"data"] count] >= 1){
        arrivals = [[[dictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"arrivals"];
    }
    for(NSDictionary * dic in arrivals){
        NSString * busID = [dic objectForKey:@"route_id"];
        NSMutableArray * arrivalTimes = [self.arrivalTimes objectForKey:busID];
        if(!arrivalTimes){
            arrivalTimes = [[NSMutableArray alloc] init];
        }
        [arrivalTimes addObject:[dic objectForKey:@"arrival_at"]];
        [self.arrivalTimes setObject:arrivalTimes forKey:busID];
    }
}

@end

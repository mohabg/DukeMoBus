//
//  BusStop.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusStop.h"

@implementation BusStop

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.stopID = [aDecoder decodeObjectForKey:@"stopID"];
        self.busIDs = [aDecoder decodeObjectForKey:@"busIDs"];
        self.latitude = [aDecoder decodeObjectForKey:@"latitude"];
        self.longitude = [aDecoder decodeObjectForKey:@"longitude"];
        self.stopName = [aDecoder decodeObjectForKey:@"stopName"];
        self.walkTime = [aDecoder decodeObjectForKey:@"walkTime"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.stopID forKey:@"stopID"];
    [aCoder encodeObject:self.busIDs forKey:@"busIDs"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.stopName forKey:@"stopName"];
    [aCoder encodeObject:self.walkTime forKey:@"walkTime"];
}

-(NSString *)getUserFriendlyName{
    NSMutableString * nameWithoutParantheses = [[NSMutableString alloc] init];
    for(int i = 0; i < _stopName.length; i++){
        if([_stopName characterAtIndex:i] == '('){
            break;
        }
        [nameWithoutParantheses appendFormat:@"%c", [_stopName characterAtIndex:i]];
    }
    return nameWithoutParantheses;
}

-(void)loadFromDictionary:(NSDictionary *)dictionary{
    self.stopName = [dictionary objectForKey:@"name"];
    self.busIDs = [dictionary objectForKey:@"routes"];
    self.stopID = [dictionary objectForKey:@"stop_id"];
    NSDictionary * location = [dictionary objectForKey:@"location"];
    self.longitude = [location objectForKey:@"lng"];
    self.latitude = [location objectForKey:@"lat"];
}
-(void)loadWalkTimes:(NSDictionary *)dictionary{
    
    //SHOULD USE BUS PARSER
    
    self.walkTime = [[[[[[dictionary objectForKey:@"rows"] objectAtIndex:0] objectForKey:@"elements" ] objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"text"];
    
}
-(NSComparisonResult)compare:(BusStop *)other{
    NSNumber * firstWalkTime = [NSNumber numberWithInteger:[self.walkTime integerValue]];
    NSNumber * secondWalkTime = [NSNumber numberWithInteger:[other.walkTime integerValue]];
    
    return [firstWalkTime compare:secondWalkTime];
}
@end

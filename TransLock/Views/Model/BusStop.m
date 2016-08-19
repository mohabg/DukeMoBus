//
//  BusStop.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusStop.h"

@implementation BusStop

#pragma mark - Initializing

-(void)loadFromDictionary:(NSDictionary *)dictionary{
    
    self.stopName = [dictionary objectForKey:@"name"];
    self.busIDs = [dictionary objectForKey:@"routes"];
    self.stopID = [dictionary objectForKey:@"stop_id"];
    NSDictionary * location = [dictionary objectForKey:@"location"];
    self.longitude = [location objectForKey:@"lng"];
    self.latitude = [location objectForKey:@"lat"];
}

#pragma mark - NSCoding Protocol

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

//#pragma mark - NSCopying Protocol
//
//-(id)copyWithZone:(NSZone *)zone{
//    id copy = [[[self class] alloc] init];
//    if(copy){
//        [copy setStopID:[self.stopID copyWithZone:zone]];
//        [copy setStopName:[self.stopName copyWithZone:zone]];
//        [copy setBusIDs:[self.busIDs copyWithZone:zone]];
//        [copy setLongitude:[self.longitude copyWithZone:zone]];
//        [copy setLatitude:[self.latitude copyWithZone:zone]];
//        [copy setWalkTime:[self.walkTime copyWithZone:zone]];
//        [copy setArrivalTimes:[self.arrivalTimes copyWithZone:zone]];
//    }
//    return copy;
//}

#pragma mark - Sorting Comparator

-(NSComparisonResult)compare:(BusStop *)other{
    
    NSNumber * firstWalkTime = [NSNumber numberWithInteger:[self.walkTime integerValue]];
    NSNumber * secondWalkTime = [NSNumber numberWithInteger:[other.walkTime integerValue]];
    
    return [firstWalkTime compare:secondWalkTime];
}

#pragma mark - Misc

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

@end

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
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.walkTime = [aDecoder decodeObjectForKey:@"walkTime"];
        self.walkTimeAsInt = [aDecoder decodeObjectForKey:@"walkTimeAsInt"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.stopID forKey:@"stopID"];
    [aCoder encodeObject:self.busIDs forKey:@"busIDs"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.walkTime forKey:@"walkTime"];
    [aCoder encodeObject:self.walkTimeAsInt forKey:@"walkTimeAsInt"];
}

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
-(void)loadWalkTimes:(NSDictionary *)dictionary{
    NSString * walkTime = [[[[[[dictionary objectForKey:@"rows"] objectAtIndex:0] objectForKey:@"elements" ] objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"text"];
    self.walkTime = walkTime;
    self.walkTimeAsInt = [NSNumber numberWithInteger:[[[walkTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t"]] objectAtIndex:0] integerValue]];
}

@end

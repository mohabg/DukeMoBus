//
//  BusParser.m
//  TransLock
//
//  Created by Mohab Gabal on 8/15/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusParser.h"
#import "APIHandler.h"


@implementation BusParser

+(void)loadRoutesIntoBusData:(BusData *)busData WithCompletion:(void (^) (NSDictionary *))completion{
    [APIHandler loadRoutesWithCompletionBlock:^(NSDictionary * jsonData) {
        NSArray<NSDictionary *> * allRoutes = [[jsonData objectForKey:@"data"] objectForKey:@"176"];
        
        for(NSDictionary * dictionary in allRoutes){;
            [busData setBusName:[dictionary objectForKey:@"long_name"] ForBusId:[dictionary objectForKey:@"route_id"]];
        }
        completion(jsonData);
    }];
}

+(NSArray *)parseArrivals:(NSArray<NSDictionary*> *)json{

    NSMutableArray * arrivalTimes = [NSMutableArray array];
        
    for(NSDictionary * arrivalsData in json){
            
        [arrivalTimes addObject:[self calculateArrivalTimeFromString:[arrivalsData objectForKey:@"arrival_at"]]];
    }
    
    return arrivalTimes;
}

+(NSString *)calculateArrivalTimeFromString:(NSString *)arrivalTimeString{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

    NSDate * arrivalDate = [dateFormatter dateFromString:arrivalTimeString];
    NSInteger timeInMins = [arrivalDate timeIntervalSinceNow];
    
    if(timeInMins < 60){
        timeInMins = 1;
    }
    else{
        timeInMins /= 60;
    }
    
    return [[NSNumber numberWithInteger:timeInMins] stringValue];
}

+(NSArray *)parseWalkTimes:(NSDictionary *)json{
    NSDictionary * rows = [json objectForKey:@"rows"];
    NSArray<NSDictionary*> * jsonWalkTimes = [[[json objectForKey:@"rows"] objectAtIndex: 0] objectForKey:@"elements"];
    NSMutableArray * walkTimes = [NSMutableArray array];
    
    for(NSDictionary * elements in jsonWalkTimes){
        
        [walkTimes addObject:[[elements objectForKey:@"duration"] objectForKey:@"text"]];
    }
    return walkTimes;
}


+(NSString *)encodingForCoordinates:(NSArray<CLLocation*> *)coordinates{
    
    return [[self stringFromLocations:coordinates] componentsJoinedByString:@"%7C"];
}

+(NSArray<NSString*> *)stringFromLocations:(NSArray<CLLocation*> *)locations{
    NSMutableArray * locationEncodings = [NSMutableArray array];
    
    for(CLLocation * loc in locations){
        
        [locationEncodings addObject:[NSString stringWithFormat:@"%f%%2C%f",loc.coordinate.latitude, loc.coordinate.longitude]];
    }
    return locationEncodings;
}

@end

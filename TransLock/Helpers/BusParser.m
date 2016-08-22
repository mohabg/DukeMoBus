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
    
    if([[busData getIdToBusNames] count] == 0){
        //Loads Available Duke Bus Route IDs and Names
        
        [APIHandler loadRoutesWithCompletionBlock:^(NSDictionary * jsonData) {
            NSArray<NSDictionary *> * allRoutes = [[jsonData objectForKey:@"data"] objectForKey:@"176"];
            
            for(NSDictionary * dictionary in allRoutes){
                //            if([[dictionary objectForKey:@"is_active"] isEqualToString:@"false"]) continue;
                
                [busData setBusName:[dictionary objectForKey:@"long_name"] ForBusId:[dictionary objectForKey:@"route_id"]];
            }
            
            completion(jsonData);
        }];
    }    
    completion(@{});
}

+(NSArray *)parseArrivals:(NSArray<NSDictionary*> *)json{

    NSMutableArray * arrivalTimes = [NSMutableArray array];
        
    for(NSDictionary * arrivalsData in json){
            
        [arrivalTimes addObject:[self calculateArrivalTimeFromString:[arrivalsData objectForKey:@"arrival_at"]]];
    }
    
    return arrivalTimes;
}

+(NSDictionary *)parseArrivalsAndRoutes:(NSArray<NSDictionary*> *)json{
    
    NSMutableDictionary * parsedData = [NSMutableDictionary dictionary];
    
    for(NSDictionary * data in json){
        
        NSString * arrivalTime = [self calculateArrivalTimeFromString:[data objectForKey:@"arrival_at"]];
        NSString * routeId = [data objectForKey:@"route_id"];
        
        NSString * shortestArrivalTime = [parsedData objectForKey:routeId];
        
        if(!shortestArrivalTime){
            
            shortestArrivalTime = arrivalTime;
        }
        if([arrivalTime integerValue] < [shortestArrivalTime integerValue]){
                
            shortestArrivalTime = arrivalTime;
        }
        
        [parsedData setObject:shortestArrivalTime forKey:routeId];
    }
    return parsedData;
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

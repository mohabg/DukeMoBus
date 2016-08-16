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
        
        for(NSDictionary * dictionary in allRoutes){
            [busData.idToBusNames setObject:[dictionary objectForKey:@"long_name"] forKey:[dictionary objectForKey:@"route_id"]];
        }
        completion(jsonData);
    }];
}

+(void)parseData:(NSArray <NSDictionary *> *)data IntoBusData:(BusData *)busData ForBusId:(NSString *)busId{
    
    for(NSDictionary * json in data){
       // NSString * stopId = [json objectForKey:@"stop_id"];

        NSArray<NSDictionary *> * vehiclesData = [json objectForKey:@"arrivals"];
        NSMutableArray * vehicles = [NSMutableArray array];
        
        for(NSDictionary * vehicleData in vehiclesData){
            
            BusVehicle * vehicle = [[BusVehicle alloc] init];
            vehicle.arrivalTimeString = [vehicleData objectForKey:@"arrival_at"];
            vehicle.arrivalTimeNumber = [self calculateArrivalTimeFromString:vehicle.arrivalTimeString];
            vehicle.busID = [vehicleData objectForKey:@"route_id"];
            
            [vehicles addObject:vehicle];
        }
    }
}

+(NSNumber *)calculateArrivalTimeFromString:(NSString *)arrivalTimeString{
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
    
    return [NSNumber numberWithInteger:timeInMins];
}

@end

//
//  BusParser.m
//  TransLock
//
//  Created by Mohab Gabal on 8/15/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusParser.h"
#import "APIHandler.h"

@interface BusParser ()

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@end

@implementation BusParser

-(instancetype)init{
    self = [super init];
    if(self){
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    }
    return self;
}

-(void)loadRoutesIntoBusData:(BusData *)busData{
    [APIHandler loadRoutesWithCompletionBlock:^(NSDictionary * jsonData) {
        NSArray<NSDictionary *> * allRoutes = [[jsonData objectForKey:@"data"] objectForKey:@"176"];
        
        for(NSDictionary * dictionary in allRoutes){
            [busData.idToBusNames setObject:[dictionary objectForKey:@"long_name"] forKey:[dictionary objectForKey:@"route_id"]];
        }
    }];
}

-(void)parseData:(NSArray <NSDictionary *> *)data IntoBusData:(BusData *)busData{
   
    for(NSDictionary * json in data){
        NSArray<NSDictionary *> * vehiclesData = [json objectForKey:@"arrivals"];
        NSString * stopId = [json objectForKey:@"stop_id"];
        
        for(NSDictionary * vehicleData in vehiclesData){
            
            BusVehicle * vehicle = [[BusVehicle alloc] init];
            vehicle.arrivalTimeString = [vehicleData objectForKey:@"arrival_at"];
            vehicle.arrivalTimeNumber = [self calculateArrivalTimeFromString:vehicle.arrivalTimeString];
            vehicle.busID = [vehicleData objectForKey:@"route_id"];
            
            [busData.vehiclesForStopID setObject:vehicle forKey:stopId];
        }
    }
}

-(NSNumber *)calculateArrivalTimeFromString:(NSString *)arrivalTimeString{
    NSDate * arrivalDate = [self.dateFormatter dateFromString:arrivalTimeString];
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

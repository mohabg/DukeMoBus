//
//  APIHandler.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "APIHandler.h"
#import "BusStop.h"
#import "BusParser.h"
#import "LocationHandler.h"

@implementation APIHandler

+(void)loadRoutesWithCompletionBlock:(void (^) (NSDictionary *))completionBlock{
    [self parseJsonWithRequest:[self createRouteRequest] CompletionBlock:^(NSDictionary * jsonData){
        
        completionBlock(jsonData);
    }];
}

+(void)parseJsonWithRequest:(NSURLRequest *)request CompletionBlock:(void (^)(NSDictionary *))completionBlock {

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * connectionError) {
        if(connectionError){
            NSLog(@"Connection failed with error: %@", [connectionError localizedDescription]);
        }
        else{
            if(!response){
                NSLog(@"NO RESPONSE FROM API REQUEST");
            }
            NSError * error = nil;
            NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments  error:&error];
            if(error){
                
                //TODO: NEED RETRY OPTION
                
                NSLog(@"JSON ERROR: %@", [error localizedDescription]);
                return;
            }
            completionBlock(jsonData);
        }
    }] resume];
}


+(NSURLRequest *)createBusStopRequestWithLatitude:(NSString *)latitude Longitude:(NSString *)longitude{
    
    NSString * urlString =[NSString stringWithFormat:@"https://transloc-api-1-2.p.mashape.com/stops.json?agencies=176&callback=call&geo_area=%@%%2C%@%%7C450", latitude, longitude];
    
    NSMutableURLRequest * busStopRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self setTranslocParameters:busStopRequest];
    
    return busStopRequest;
}

+(NSURLRequest *)createWalkTimeRequestFromLocation:(CLLocation *)from ToLocations:(NSArray<CLLocation*> *)to{
    
    NSString * userLoc = [BusParser encodingForCoordinates:[NSArray arrayWithObject:from]];
    NSString * desinationsLoc = [BusParser encodingForCoordinates:to];
    
//    NSString * userLat = @"36.004162";
//    NSString * userLng = @"-78.931327";
//    
//    userLoc = [NSString stringWithFormat:@"%@,%@",userLat, userLng];
    
    NSURLRequest * walkTimeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=walking&language=en&key=AIzaSyC2MS3CUnzd_oIsjZ4OjDPSgPgVZAylHlk", userLoc, desinationsLoc]]];
    
    return walkTimeRequest;
}

+(NSURLRequest *)createRouteRequest{
    
    NSMutableURLRequest * routeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://transloc-api-1-2.p.mashape.com/routes.json?agencies=176&callback=call"]];
    [self setTranslocParameters:routeRequest];
    
    return routeRequest;
}

+(NSURLRequest *)createRandomJokeRequest{
    
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.icndb.com/jokes/random?firstName=Mohab&lastName=Gabal"]];
}

+(NSURLRequest *)createArrivalTimeRequestForStop:(NSString *)stop Buses:(NSArray *)buses{
    NSString * busesEncoding = [[NSString alloc] init];
    for(NSString * bus in buses){
       busesEncoding = [busesEncoding stringByAppendingString:[NSString stringWithFormat:@"%@%%2C", bus]];
    }
    busesEncoding = [busesEncoding substringToIndex:[busesEncoding length] - 3];
    NSString * urlString =  [NSString stringWithFormat:@"https://transloc-api-1-2.p.mashape.com/arrival-estimates.json?agencies=176&callback=call&routes=%@&stops=%@", busesEncoding, stop];
    NSMutableURLRequest * arrivalTimeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self setTranslocParameters:arrivalTimeRequest];
    
    return arrivalTimeRequest;
}

+(NSURLRequest *)createArrivalTimeRequestForStops:(NSArray *)stops Buses:(NSArray *)buses{
    NSString * busesEncoding = [buses componentsJoinedByString:@"%2C"];
    NSString * stopsEncoding = [stops componentsJoinedByString:@"%2C"];

    NSMutableURLRequest * arrivalTimeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://transloc-api-1-2.p.mashape.com/arrival-estimates.json?agencies=176&callback=call&routes=%@&stops=%@", busesEncoding, stopsEncoding]]];
    
    [self setTranslocParameters:arrivalTimeRequest];
    
    return arrivalTimeRequest;
}

+(void)setTranslocParameters:(NSMutableURLRequest *)request{
    
    //TODO: Hide access keys for better security
    
    [request setValue:@"PCG5uRLF4ZmshAIGO5Uv2Oyqbx8sp1qjiz9jsnFDMawMbwhuy8" forHTTPHeaderField:@"X-Mashape-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
}

@end

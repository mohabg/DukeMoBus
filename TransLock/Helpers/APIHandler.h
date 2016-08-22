//
//  APIHandler.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BusStop.h"
#import "BusData.h"

@interface APIHandler : NSObject

+(void)loadRoutesWithCompletionBlock:(void (^) (NSDictionary *))completionBlock;

+(void)parseJsonWithRequest:(NSURLRequest *)request CompletionBlock:(void (^)(NSDictionary *))completionBlock;

+(NSURLRequest *)createBusStopRequestWithLatitude:(NSString *)latitude Longitude:(NSString *)longitude;

+(NSURLRequest *)createWalkTimeRequestFromLocation:(CLLocation *)from ToLocations:(NSArray<CLLocation*> *)to;

+(NSURLRequest *)createRouteRequest;

+(NSURLRequest *)createRandomJokeRequest;

+(NSURLRequest *)createArrivalTimeRequestForStops:(NSArray *)stops Buses:(NSArray *)buses;

@end

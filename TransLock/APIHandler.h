//
//  APIHandler.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStop.h"
#import "BusData.h"

@interface APIHandler : NSObject


-(void)parseJsonWithRequest:(NSURLRequest *)request CompletionBlock:(void (^)(NSDictionary *))completionBlock;

-(void)loadAPIDataIntoBusData:(BusData *)busData UsingLat:(NSString *)lat Long:(NSString *)lng;

-(NSURLRequest *)createBusStopRequestWithLatitude:(NSString *)latitude Longitude:(NSString *)longitude;

-(NSURLRequest *)createWalkTimeRequestWithLatitude:(NSString *)latitude Longitude:(NSString *)longitude BusStop:(BusStop *)busStop;

-(NSURLRequest *)createRouteRequest;

-(NSURLRequest *)createRandomJokeRequest;

-(NSURLRequest *)createArrivalTimeRequestForStop:(NSString *)stop Buses:(NSArray *)buses;

-(NSURLRequest *)createArrivalTimeRequestForStops:(NSArray *)stops Buses:(NSArray *)buses;

@end

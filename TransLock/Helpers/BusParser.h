//
//  BusParser.h
//  TransLock
//
//  Created by Mohab Gabal on 8/15/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BusStop.h"
#import "BusData.h"

@interface BusParser : NSObject

+(NSArray *)parseArrivals:(NSArray<NSDictionary*> *)json;
+(NSArray *)parseWalkTimes:(NSDictionary *)json;

+(void)loadRoutesIntoBusData:(BusData *)busData WithCompletion:(void (^) (NSDictionary *))completion;

+(NSString *)encodingForCoordinates:(NSArray<CLLocation*> *)coordinates;

@end

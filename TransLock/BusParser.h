//
//  BusParser.h
//  TransLock
//
//  Created by Mohab Gabal on 8/15/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStop.h"
#import "BusVehicle.h"
#import "BusData.h"

@interface BusParser : NSObject

+(void)parseData:(NSArray <NSDictionary *> *)data IntoBusData:(BusData *)busData ForBusId:(NSString *)busId;

+(void)loadRoutesIntoBusData:(BusData *)busData WithCompletion:(void (^) (NSDictionary *))completion;

@end

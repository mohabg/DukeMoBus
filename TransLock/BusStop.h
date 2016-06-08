//
//  BusStop.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusStop : NSObject

@property (nonatomic, strong) NSString * stopID;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSArray * busIDs;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * walkTime;
@property (nonatomic, strong) NSNumber * walkTimeAsInt;
@property (nonatomic, strong) NSMutableDictionary * arrivalTimes;

-(NSString *)getUserFriendlyName;

-(void)loadFromDictionary:(NSDictionary *)dictionary;
-(void)loadArrivalTimes:(NSDictionary *)dictionary;
-(void)loadWalkTimes:(NSDictionary *)dictionary;

@end

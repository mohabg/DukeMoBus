//
//  BusData.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusData.h"

@implementation BusData

-(instancetype)init{
    self = [super init];
    if(self){
        self.busStops = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

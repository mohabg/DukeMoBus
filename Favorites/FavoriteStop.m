//
//  FavoriteStop.m
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "FavoriteStop.h"

@implementation FavoriteStop

-(instancetype)initWithBusTitle:(NSString *)busTitle StopTitle:(NSString *)stopTitle ArrivalTime:(NSString *)arrivalTime{
    
    self = [super init];
    if(self){
        
        self.busTitle = busTitle;
        self.stopTitle = stopTitle;
        self.arrivalTime = arrivalTime;
    }
    return self;
}

-(NSString *)getUserFriendlyBusTitle{
   
    NSRange userFriendlyRange = [self.busTitle rangeOfString:@":"];
    if(userFriendlyRange.location == NSNotFound){
        userFriendlyRange = [self.busTitle rangeOfString:@" "];
    }
    
    return [self.busTitle substringWithRange:userFriendlyRange];
}

@end

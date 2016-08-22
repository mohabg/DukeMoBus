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
    
    NSInteger colonOrSpace;
    
    for(int i = 0; i < self.busTitle.length; i++){
        
        NSString * charString = [NSString stringWithFormat:@"%c", [self.busTitle characterAtIndex:i]];
        
        if([charString isEqualToString:@":"] || [charString isEqualToString:@" "]){
            
            colonOrSpace = i;
            break;
        }
    }
   
    return [self.busTitle substringToIndex:colonOrSpace];
}

@end

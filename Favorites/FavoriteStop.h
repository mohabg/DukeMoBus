//
//  FavoriteStop.h
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteStop : NSObject

@property (nonatomic, strong) NSString * busTitle;
@property (nonatomic, strong) NSString * stopTitle;

@property (nonatomic, strong) NSString * arrivalTime;

-(instancetype)initWithBusTitle:(NSString *)busTitle StopTitle:(NSString *)stopTitle ArrivalTime:(NSString *)arrivalTime;

-(NSString *)getUserFriendlyBusTitle;

@end

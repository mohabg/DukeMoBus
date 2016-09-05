//
//  SharedMethods.h
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BusRoute.h"
#import "BusStop.h"

@interface SharedMethods : NSObject

+(UIActivityIndicatorView *)createAndCenterLoadingIndicatorInView:(UIView *)view;

+(NSString *)getArchivePathUsingString:(NSString *)path;

+(NSString *)walkingTimeString:(NSString *)walkTime;

+(NSString *)getUserFriendlyStopName:(NSString *)stopName;

+(NSString *)getUserFriendlyBusTitle:(NSString *)busTitle;

+(NSArray<BusRoute*> *)unarchiveFavRoutes;

+(NSArray<BusStop*> *)unarchiveFavStops;

+(void)swapFrom:(NSInteger)from To:(NSInteger)to InArray:(NSMutableArray *)array;

@end


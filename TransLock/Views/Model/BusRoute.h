//
//  BusRoute.h
//  DukeMoBus
//
//  Created by Mohab Gabal on 8/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusRoute : NSObject

@property (nonatomic, strong) NSString * routeName;

@property (nonatomic, strong) NSString * routeId;

@property (nonatomic, assign) BOOL isActive;

-(instancetype)initWithRouteId:(NSString *)routeId Name:(NSString *)routeName IsActive:(BOOL)isActive;

@end

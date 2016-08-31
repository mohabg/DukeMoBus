//
//  BusRoute.m
//  DukeMoBus
//
//  Created by Mohab Gabal on 8/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusRoute.h"

@implementation BusRoute

-(instancetype)initWithRouteId:(NSString *)routeId Name:(NSString *)routeName IsActive:(BOOL)isActive{
    
    self = [super init];
    if(self){
        self.routeId = routeId;
        self.routeName = routeName;
        self.isActive = isActive;
    }
    return self;
}

@end

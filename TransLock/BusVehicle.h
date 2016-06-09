//
//  BusVehicle.h
//  TransLock
//
//  Created by Mohab Gabal on 6/8/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusVehicle : NSObject

@property (strong, nonatomic) NSString * busID;
@property (strong, nonatomic) NSString * busName;
@property (strong, nonatomic) NSString * arrivalTimeString;
@property (strong, nonatomic) NSNumber * arrivalTimeNumber;

@end

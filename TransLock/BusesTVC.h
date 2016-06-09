//
//  BusesTVC.h
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusData.h"

@interface BusesTVC : UITableViewController <NSCoding>

@property (nonatomic, strong) BusData * busData;

@end

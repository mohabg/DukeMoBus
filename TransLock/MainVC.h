//
//  MainVC.h
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController <NSCoding>

@property (strong, nonatomic) NSMutableArray * allowedBusIDs;
@property (nonatomic, strong) NSDictionary * busIDsToNames;

@end

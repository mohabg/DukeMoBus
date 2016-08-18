//
//  BusStopCell.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusStopCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *busStopLabel;
@property (strong, nonatomic) IBOutlet UILabel *walkTimeLabel;
@property (strong, nonatomic) NSArray * busTimeLabels;

@end

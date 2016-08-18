//
//  ClearTableViewCell.h
//  TransLock
//
//  Created by Mohab Gabal on 6/14/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusStopsTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel * busStopNameLabel;
@property (strong, nonatomic) IBOutlet UILabel * busStopWalkingLabel;

@property (strong, nonatomic) IBOutlet UILabel * firstBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel * secondBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel * thirdBusTimeLabel;

-(void)setSelected;
-(void)setDeSelected;

@end

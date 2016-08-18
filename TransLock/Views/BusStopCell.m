//
//  BusStopCell.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusStopCell.h"
@interface BusStopCell ()

@property (strong, nonatomic) IBOutlet UILabel *firstBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *fourthBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *fifthBusTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *sixthBusTimeLabel;

@end

@implementation BusStopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.busTimeLabels = [[NSArray alloc] initWithObjects:self.firstBusTimeLabel, self.secondBusTimeLabel, self.thirdBusTimeLabel, self.fourthBusTimeLabel, self.fifthBusTimeLabel, self.sixthBusTimeLabel, nil];
}
@end

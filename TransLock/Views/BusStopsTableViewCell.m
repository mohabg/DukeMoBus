//
//  ClearTableViewCell.m
//  TransLock
//
//  Created by Mohab Gabal on 6/14/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusStopsTableViewCell.h"

@interface BusStopsTableViewCell ()


@end

@implementation BusStopsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textLabel.textColor = [UIColor whiteColor];
}

-(void)setSelected{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:156 alpha:0.4];
}

-(void)setDeSelected{
    self.backgroundColor = [UIColor clearColor];
}

@end

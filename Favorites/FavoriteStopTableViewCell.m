//
//  FavoriteStopTableViewCell.m
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "FavoriteStopTableViewCell.h"

@implementation FavoriteStopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat)cellHeight{
    
    CGFloat busHeight = _busTitleLabel.frame.size.height;
    CGFloat stopHeight = _stopNameLabel.frame.size.height;
    CGFloat arrivalHeight = _arrivalTimeLabel.frame.size.height;
    
    CGFloat maxHeight = busHeight;
    
    if(stopHeight > maxHeight){
        maxHeight = stopHeight;
    }
    if(arrivalHeight > maxHeight){
        maxHeight = arrivalHeight;
    }
    
    return maxHeight;
}

@end

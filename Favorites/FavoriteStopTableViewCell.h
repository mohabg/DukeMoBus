//
//  FavoriteStopTableViewCell.h
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteStopTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *busTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *stopNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *arrivalTimeLabel;

@end

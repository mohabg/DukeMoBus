//
//  BusesCollectionViewController.h
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusData.h"

@interface BusesCollectionVC : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) BusData * busData;

@end

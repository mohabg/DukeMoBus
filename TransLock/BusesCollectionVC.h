//
//  BusesCollectionViewController.h
//  TransunLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusesCollectionVC : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray * allowedBusIDs;
@property (nonatomic, strong) NSDictionary * busIDsToNames;

-(void)useLocationToFetchData;
-(void)startLocationHandler;

@end

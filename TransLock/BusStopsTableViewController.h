//
//  BusStopsTableViewController.h
//  Pods
//
//  Created by Mohab Gabal on 8/13/16.
//
//

#import <UIKit/UIKit.h>
#import "BusData.h"

@interface BusStopsTableViewController : UITableViewController

@property (nonatomic,strong) BusData * busData;

-(void)findStopsForBusId:(NSString *)busId;

@end

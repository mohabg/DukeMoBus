//
//  BusesCollectionViewController.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusesCollectionVC.h"
#import "BusVehicle.h"
#import "BusStopCell.h"
#import "BusData.h"
#import "BusStop.h"
#import "BusesTVC.h"
#import <QuartzCore/QuartzCore.h>

@interface BusesCollectionVC ()

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation BusesCollectionVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.flowLayout setMinimumInteritemSpacing:0.0f];
    [self.flowLayout setMinimumLineSpacing:0.0f];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"BusStopCell" bundle:nil] forCellWithReuseIdentifier:@"BusStopCell"];
}

#pragma mark <UICollectionViewDataSource>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width / 2),200);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.busData.busStops count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BusStopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BusStopCell" forIndexPath:indexPath];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"walkTimeAsInt"
                                                                   ascending:YES];
    self.busData.busStops = [NSMutableArray arrayWithArray:[self.busData.busStops sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    BusStop * stopForIndex = [self.busData.busStops objectAtIndex:indexPath.row];
    NSArray * selectedBusesForStop = [self removeBusesNotChosenInArray:[self.busData.vehiclesForStopID objectForKey:stopForIndex.stopID]];
    [self calculateAndSortArrivalTimes:selectedBusesForStop];
    for(int i = 0; i < [cell.busTimeLabels count] && i < [selectedBusesForStop count]; i++){
        UILabel * busTimeLabel = [cell.busTimeLabels objectAtIndex:i];
        BusVehicle * bus = [selectedBusesForStop objectAtIndex:i];
        //busTimeLabel.text = [NSString stringWithFormat:@"%@ No Service", [self abbreviatedBusName:busName]];
        busTimeLabel.text = [NSString stringWithFormat:@"%@ %@ m", [self abbreviatedBusName:bus.busName],bus.arrivalTimeNumber];
    }
    cell.walkTimeLabel.text = [NSString stringWithFormat:@"%@ walking", stopForIndex.walkTime];
    cell.busStopLabel.text = [stopForIndex getUserFriendlyName];
    cell.layer.borderWidth = 2.0f;
    cell.layer.borderColor = [UIColor blueColor].CGColor;
    [cell sizeToFit];
    return cell;
}

#pragma Helper Methods

-(NSArray *)removeBusesNotChosenInArray:(NSArray *)buses{
    NSMutableArray * busesToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * selectedBusesForStop = [[NSMutableArray alloc] initWithArray:buses];
    for(int i = 0; i < [selectedBusesForStop count]; i++){
        BusVehicle * selectedBus = [selectedBusesForStop objectAtIndex:i];
        NSString * selectedBusID = selectedBus.busID;
        if(![self busID:selectedBusID isOneOfChosenBusIDs:self.busData.allowedBusIDs]){
            [busesToRemove addObject:selectedBusID];
        }
    }
    [selectedBusesForStop removeObjectsInArray:busesToRemove];
    return selectedBusesForStop;
}
-(BOOL)busID:(NSString *)busID isOneOfChosenBusIDs:(NSArray *)chosenBusIDs{
    for(NSString * allowedBus in chosenBusIDs){
        if([busID isEqualToString:allowedBus]){
            return true;
        }
    }
    return false;
}

-(void)calculateAndSortArrivalTimes:(NSArray *)arrivalTimes{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    for(int i = 0; i < [arrivalTimes count]; i++){
        BusVehicle * bus = [arrivalTimes objectAtIndex:i];
        NSDate * arrivalDate = [dateFormat dateFromString:bus.arrivalTimeString];
        NSInteger timeInMins = [arrivalDate timeIntervalSinceDate:[NSDate date]];
        if(timeInMins < 60){
            timeInMins = 1;
        }
        else{
            timeInMins %= 60;
        }
        bus.arrivalTimeNumber = [NSNumber numberWithInteger:timeInMins];
    }
    arrivalTimes = [arrivalTimes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"arrivalTimeNumber" ascending:YES]]];
    }


-(NSString *)abbreviatedBusName:(NSString *)busName{
    NSMutableString * abbreviatedName = [[NSMutableString alloc] init];
    for(int i = 0; i < busName.length; i++){
        [abbreviatedName appendFormat:@"%c", [busName characterAtIndex:i]];
        if([busName characterAtIndex:i] == ':'){
            break;
        }
    }
    return abbreviatedName;
}

@end

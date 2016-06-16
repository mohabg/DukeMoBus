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
@property (strong, nonatomic) NSDateFormatter * dateFormatter;
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
    NSArray * selectedVehiclesForStop = [self removeBusesNotChosenInArray:[self.busData.vehiclesForStopID objectForKey:stopForIndex.stopID]];
    NSMutableArray * selectedBusesForStop = [[NSMutableArray alloc] initWithArray:[self removeBusesNotChosenInArray:stopForIndex.busIDs]];
    selectedVehiclesForStop = [self calculateAndSortArrivalTimes:selectedVehiclesForStop];
    
    int remainingBusesIndex = 0;
    for(int i = 0; i < [cell.busTimeLabels count]; i++){
        UILabel * busTimeLabel = [cell.busTimeLabels objectAtIndex:i];
        busTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05f];
        
        if(i < [selectedVehiclesForStop count]){
            BusVehicle * bus = [selectedVehiclesForStop objectAtIndex:i];
            NSMutableArray * busesToRemove = [[NSMutableArray alloc] init];
            for(NSString * busID in selectedBusesForStop){
                if([busID isEqualToString:bus.busID]){
                    [busesToRemove addObject:busID];
                }
            }
            [selectedBusesForStop removeObjectsInArray:busesToRemove];
            //TODO: Add Color Coding Depending On Mins
            busTimeLabel.text = [NSString stringWithFormat:@"%@ %@ m", [self abbreviatedBusName:bus.busName],bus.arrivalTimeNumber];
            int timeToSpare = [bus.arrivalTimeNumber intValue] - [stopForIndex.walkTimeAsInt intValue];
            NSLog(@"%@ %d",stopForIndex.walkTime,timeToSpare);
            if(timeToSpare > 0 && timeToSpare < 5){
                busTimeLabel.textColor = [UIColor redColor];
            }
            else if(timeToSpare >= 5 && timeToSpare < 10){
                busTimeLabel.textColor = [UIColor yellowColor];
            }
            else if(timeToSpare > 10){
                busTimeLabel.textColor = [UIColor greenColor];
            }
            continue;
        }
        
        if(remainingBusesIndex < [selectedBusesForStop count]){
            busTimeLabel.text = [NSString stringWithFormat:@"%@ No Service", [self abbreviatedBusName:[self.busData.idToBusNames objectForKey:[selectedBusesForStop objectAtIndex:remainingBusesIndex++]]]];
        }
        else{
            busTimeLabel.text = @"";
        }
    }
    
    cell.walkTimeLabel.text = [NSString stringWithFormat:@"%@ walking", stopForIndex.walkTime];
    cell.busStopLabel.text = [stopForIndex getUserFriendlyName];
    cell.layer.borderWidth = 0.25f;
    [cell sizeToFit];
    return cell;
}

#pragma mark - Helper Methods

-(NSArray *)removeBusesNotChosenInArray:(NSArray *)buses{
    NSMutableArray * busesToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * selectedBusesForStop = [[NSMutableArray alloc] initWithArray:buses];
    for(int i = 0; i < [selectedBusesForStop count]; i++){
        NSString * selectedBusID = [selectedBusesForStop objectAtIndex:i];
        if([selectedBusID isKindOfClass:[BusVehicle class]]){
            BusVehicle * selectedBus = (BusVehicle *) selectedBusID;
            selectedBusID = selectedBus.busID;
        }
        if(![self.busData allowedBusIDsContainsBusID:selectedBusID]){
            [busesToRemove addObject:[selectedBusesForStop objectAtIndex:i]];
        }
    }
    [selectedBusesForStop removeObjectsInArray:busesToRemove];
    return selectedBusesForStop;
}

-(NSArray * )calculateAndSortArrivalTimes:(NSArray *)arrivalTimes{
    
    for(int i = 0; i < [arrivalTimes count]; i++){
        BusVehicle * bus = [arrivalTimes objectAtIndex:i];
        NSDate * arrivalDate = [self.dateFormatter dateFromString:bus.arrivalTimeString];
        NSInteger timeInMins = [arrivalDate timeIntervalSinceNow];
        if(timeInMins < 60){
            timeInMins = 1;
        }
        else{
            timeInMins /= 60;
        }
        bus.arrivalTimeNumber = [NSNumber numberWithInteger:timeInMins];
    }
    return [arrivalTimes sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"arrivalTimeNumber" ascending:YES]]];
    }

-(NSDateFormatter *)dateFormatter{
    if(_dateFormatter == nil){
        NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        _dateFormatter = dateFormat;
    }
    return _dateFormatter;
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

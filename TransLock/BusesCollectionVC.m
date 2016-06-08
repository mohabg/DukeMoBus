//
//  BusesCollectionViewController.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "BusesCollectionVC.h"
#import "BusStopCell.h"
#import "BusData.h"
#import "BusStop.h"
#import "BusesTVC.h"
#import "APIHandler.h"
#import "LocationHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface BusesCollectionVC ()

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) BusData * myBusData;
@property (nonatomic, strong) LocationHandler * locationHandler;
@property (nonatomic, strong) APIHandler * handler;
@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;

@end

@implementation BusesCollectionVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([self.allowedBusIDs count] > 0){
        self.locationHandler = [[LocationHandler alloc] init];
        self.locationHandler.busesController = self;
        [self startLocationHandler];
    }
}
-(void)startLocationHandler{
    [self.locationHandler start];
}
-(void)useLocationToFetchData{
    self.myBusData = [[BusData alloc] init];
    NSMutableArray * busStops = self.myBusData.busStops;
    self.locationHandler.latitude = @"36.005144";
    self.locationHandler.longitude = @"-78.944213";
    NSString * lat = self.locationHandler.latitude;
    NSString * lng = self.locationHandler.longitude;
    
    self.loadingIndicator = [self startIndicatorView];
    
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
        [self.handler parseJsonWithRequest:[self.handler createBusStopRequestWithLatitude:lat Longitude:lng] CompletionBlock:^(NSDictionary * jsonData){
            //Load Bus Stops In Area
            NSArray * dataArr = [jsonData objectForKey:@"data"];
            for(int i = 0; i < [dataArr count]; i++){
                
                BusStop * busStop = [[BusStop alloc] init];
                [busStop loadFromDictionary: [dataArr objectAtIndex:i] ];
                for(NSString * busID in busStop.busIDs){
                    BOOL goToNextBusStop = FALSE;
                    for(NSString * allowedID in self.allowedBusIDs){
                        if([busID isEqualToString:allowedID]){
                            [busStops addObject:busStop];
                            goToNextBusStop = TRUE;
                            break;
                        }
                    }
                    if(goToNextBusStop){
                        break;
                    }
                }
                dispatch_group_enter(group);
                [self.handler parseJsonWithRequest:[self.handler createArrivalTimeRequestForStop:busStop.stopID Buses:self.allowedBusIDs] CompletionBlock:^(NSDictionary * json){
                    [busStop loadArrivalTimes:json];
                    dispatch_group_leave(group);
                }];
                dispatch_group_enter(group);
                [self.handler parseJsonWithRequest:[self.handler createWalkTimeRequestWithLatitude:lat Longitude:lng BusStop:busStop] CompletionBlock:^(NSDictionary * json){
                    [busStop loadWalkTimes:json];
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_leave(group);
        }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.loadingIndicator stopAnimating];
    });
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handler = [[APIHandler alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:(self) selector:@selector(startLocationHandler)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self.flowLayout setMinimumInteritemSpacing:0.0f];
    [self.flowLayout setMinimumLineSpacing:0.0f];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"BusStopCell" bundle:nil] forCellWithReuseIdentifier:@"BusStopCell"];
}

-(UIActivityIndicatorView *)startIndicatorView{
    
    UIActivityIndicatorView * loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    loadingIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0);
    [self.view addSubview:loadingIndicator];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loadingIndicator
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loadingIndicator
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    [loadingIndicator startAnimating];
    
    return loadingIndicator;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width / 2),200);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.myBusData.busStops count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BusStopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BusStopCell" forIndexPath:indexPath];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"walkTimeAsInt"
                                                                   ascending:YES];
    self.myBusData.busStops = [NSMutableArray arrayWithArray:[self.myBusData.busStops sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    BusStop * stopForIndex = [self.myBusData.busStops objectAtIndex:indexPath.row];
    NSNumber * index = [[NSNumber alloc] initWithInt:0];
    NSArray * arrivalTimesInMins = [[NSArray alloc] init];
    NSString * busName;
    NSArray * selectedBusesForStop = [self removeBusesNotChosenInArray:stopForIndex.busIDs];
    for(NSString * busID in selectedBusesForStop){
        busName = [self.busIDsToNames objectForKey:busID];
        NSArray * arrivalTimes = [stopForIndex.arrivalTimes objectForKey:busID];
        if(!arrivalTimes){
          index = [self setText:[NSString stringWithFormat:@"%@ No Service", [self abbreviatedBusName:busName]] ForLabelOnCell:cell AtIndex:index];
        }
        else{
            arrivalTimesInMins = [self calculateAndSortArrivalTimes:arrivalTimes];
            for(int i = 0; i < [arrivalTimesInMins count]; i++){
                index = [self setText:[NSString stringWithFormat:@"%@ %@ min", [self abbreviatedBusName:busName], [arrivalTimesInMins objectAtIndex:i]] ForLabelOnCell:cell AtIndex:index];
            }
        }
    }
    cell.walkTimeLabel.text = [NSString stringWithFormat:@"%@ walking", stopForIndex.walkTime];
    cell.busStopLabel.text = [stopForIndex getUserFriendlyName];
    cell.layer.borderWidth = 2.0f;
    cell.layer.borderColor = [UIColor blueColor].CGColor;
    [cell sizeToFit];
    return cell;
}
-(NSArray *)removeBusesNotChosenInArray:(NSArray *)buses{
    NSMutableArray * busesToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * selectedBusesForStop = [[NSMutableArray alloc] initWithArray:buses];
    for(int i = 0; i < [selectedBusesForStop count]; i++){
        NSString * selectedBus = [selectedBusesForStop objectAtIndex:i];
        if(![self busID:selectedBus isOneOfChosenBusIDs:self.allowedBusIDs]){
            [busesToRemove addObject:selectedBus];
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
-(NSNumber *)setText:(NSString *)text ForLabelOnCell:(BusStopCell *)cell AtIndex:(NSNumber *)index{
    int indexInt = [index intValue];
    if(indexInt >= [cell.busTimeLabels count]){
        return index;
    }
    UILabel * busTimeLabel = [cell.busTimeLabels objectAtIndex:indexInt];
    busTimeLabel.text = text;
    return [NSNumber numberWithInt:indexInt + 1];
}

-(NSArray *)calculateAndSortArrivalTimes:(NSArray *)arrivalTimes{
    NSMutableArray * arrivalTimesInMins = [[NSMutableArray alloc] init];
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    for(int i = 0; i < [arrivalTimes count]; i++){
        NSDate * arrivalDate = [dateFormat dateFromString:[arrivalTimes objectAtIndex:i]];
        NSInteger timeInMins = [arrivalDate timeIntervalSinceDate:[NSDate date]];
        if(timeInMins < 60){
            timeInMins = 1;
        }
        else{
            timeInMins %= 60;
        }
        [arrivalTimesInMins addObject:[NSNumber numberWithInteger:timeInMins]];
    }
    [arrivalTimesInMins sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    
    return arrivalTimesInMins;
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

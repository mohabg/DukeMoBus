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
#import "APIHandler.h"
#import "LocationHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface BusesCollectionVC ()

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) LocationHandler * locationHandler;
@property (nonatomic, strong) APIHandler * handler;
@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;

@end

@implementation BusesCollectionVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([self.busData.allowedBusIDs count] > 0){
        self.locationHandler = [[LocationHandler alloc] init];
        self.locationHandler.busesController = self;
        [self startLocationHandler];
    }
}

-(void)useLocationToFetchData{
    NSMutableArray * busStops = self.busData.busStops;
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
                    BOOL breakOuterLoop = FALSE;
                    for(NSString * allowedID in self.busData.allowedBusIDs){
                        if([busID isEqualToString:allowedID]){
                            [busStops addObject:busStop];
                            breakOuterLoop = TRUE;
                            break;
                        }
                    }
                    if(breakOuterLoop){
                        break;
                    }
                }
                dispatch_group_enter(group);
                [self.handler parseJsonWithRequest:[self.handler createArrivalTimeRequestForStop:busStop.stopID Buses:self.busData.allowedBusIDs] CompletionBlock:^(NSDictionary * json){
                    [self.busData loadArrivalTimes:json ForStopID:busStop.stopID];
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
        busTimeLabel.text = [NSString stringWithFormat:@"%@ %@ min", [self abbreviatedBusName:bus.busName],bus.arrivalTimeNumber];
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

-(void)startLocationHandler{
    [self.locationHandler start];
}

@end

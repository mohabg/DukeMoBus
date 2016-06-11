//
//  MainVC.m
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "MainVC.h"
#import "BusesTVC.h"
#import "BusesCollectionVC.h"
#import "APIHandler.h"
#import "LocationHandler.h"

@interface MainVC ()

@property (strong, nonatomic) IBOutlet UILabel * jokeLabel;
@property (strong, nonatomic) APIHandler * handler;
@property (strong, nonatomic) LocationHandler * locationHandler;
@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;
@property (strong, nonatomic) UICollectionView * collectionView;

@end

@implementation MainVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([self.busData.allowedBusIDs count] == 0){
        [self performSegueWithIdentifier:@"EditBuses" sender:self];
    }
    else{
        [self startIndicatorView];
        
        [self.locationHandler start];
        
        [self getRandomJoke];
        
        [self.loadingIndicator stopAnimating];
    }
}
-(void)getData{
    if([self.busData.allowedBusIDs count] == 0){
        return;
    }
    [self.handler loadAPIDataIntoBusData:self.busData UsingLat:self.locationHandler.latitude Long:self.locationHandler.longitude];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handler = [[APIHandler alloc] init];
    
    self.locationHandler = [[LocationHandler alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:(self) selector:@selector(refreshView:) name:@"Location Received" object:nil];
}
-(void)refreshView:(NSNotification *)notification{
    [self getData];
    [self.collectionView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:(self) name:@"Location Received" object:nil];
}
-(void)getRandomJoke{
    [self.handler parseJsonWithRequest:[self.handler createRandomJokeRequest] CompletionBlock:^(NSDictionary * jsonData){
        NSString * randomJoke = [[jsonData objectForKey:@"value"] objectForKey:@"joke"];
        NSString * randomJokeEscapeQuotes = [randomJoke stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        NSString * randomJokeEscapeQuotesAndApostrophes = [randomJokeEscapeQuotes stringByReplacingOccurrencesOfString:@"' " withString:@"'s "];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.jokeLabel.text = randomJokeEscapeQuotesAndApostrophes;
        });

    }];

}
- (IBAction)refreshJoke:(id)sender {
    [self getRandomJoke];
}

-(void)startIndicatorView{
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0);
    self.loadingIndicator.hidden = NO;
    [self.view addSubview:self.loadingIndicator];
    [self.view bringSubviewToFront:self.loadingIndicator];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.loadingIndicator startAnimating];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController * destination = [segue destinationViewController];
    if([segue.identifier isEqualToString:@"embedCollection"]){
        BusesCollectionVC * busCollectionController = (BusesCollectionVC *) destination;
        busCollectionController.busData = self.busData;
        self.collectionView = busCollectionController.collectionView;
    }
    if([segue.identifier isEqualToString:@"EditBuses"]){
        UINavigationController * navController = (UINavigationController *) destination;
        BusesTVC * busTableController = (BusesTVC *) navController.visibleViewController;
        busTableController.busData = self.busData;
    }
}
@end

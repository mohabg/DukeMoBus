//
//  MainVC.m
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "MainVC.h"
#import "BusesCollectionVC.h"
#import "BusParser.h"
#import "APIHandler.h"
#import "LocationHandler.h"

@interface MainVC ()

@property (strong, nonatomic) IBOutlet UILabel * jokeLabel;
@property (strong, nonatomic) LocationHandler * locationHandler;
@property (strong, nonatomic) UIActivityIndicatorView * loadingIndicator;
@property (strong, nonatomic) UICollectionView * collectionView;

@end

@implementation MainVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
 
    [self requestDataForView];
}

-(void)requestDataForView{
    [self startIndicatorView];
    
    [self.locationHandler start];
    
    [self getRandomJoke];
    
    [BusParser loadRoutesIntoBusData:self.busData WithCompletion:^(NSDictionary * json){
        [self.collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationHandler = [[LocationHandler alloc] init];
    
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
    

}

-(void)getRandomJoke{
    [APIHandler parseJsonWithRequest:[APIHandler createRandomJokeRequest] CompletionBlock:^(NSDictionary * jsonData){
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
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.layer.cornerRadius = 05;
    self.loadingIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    [self.loadingIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.transform = CGAffineTransformMakeScale(3.5, 3.5);
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
}
@end

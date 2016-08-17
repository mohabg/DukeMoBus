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

@end

@implementation MainVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 
    [self requestDataForView];
}

-(void)requestDataForView{
//    [self startIndicatorView];
//    
    [self getRandomJoke];
//    
//    [BusParser loadRoutesIntoBusData:self.busData WithCompletion:^(NSDictionary * json){
//        [self.collectionView reloadData];
//        [self stopIndicatorView];
//    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"embedCollection"]){
        BusesCollectionVC * busCollectionController = (BusesCollectionVC *) [segue destinationViewController];
        
        busCollectionController.busData = self.busData;
    }
}
@end

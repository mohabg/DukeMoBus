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

@import CoreData;

@interface MainVC ()

@property (strong, nonatomic) IBOutlet UILabel * jokeLabel;
@property (strong, nonatomic) APIHandler * handler;

@end

@implementation MainVC

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([self.busData.allowedBusIDs count] == 0){
        [self performSegueWithIdentifier:@"EditBuses" sender:self];
    }
    
    [self getRandomJoke];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handler = [[APIHandler alloc] init];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController * destination = [segue destinationViewController];
    if([segue.identifier isEqualToString:@"embedCollection"]){
        BusesCollectionVC * busCollectionController = (BusesCollectionVC *) destination;
        busCollectionController.busData = self.busData;
    }
    if([segue.identifier isEqualToString:@"EditBuses"]){
        UINavigationController * navController = (UINavigationController *) destination;
        BusesTVC * busTableController = (BusesTVC *) navController.visibleViewController;
        busTableController.busData = self.busData;
    }
}
@end

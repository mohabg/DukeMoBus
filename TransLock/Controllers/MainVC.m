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
#import "FavoritesTableViewController.h"
#import "APIHandler.h"
#import "LocationHandler.h"
#import "SharedMethods.h"

@interface MainVC ()

@property (strong, nonatomic) IBOutlet UILabel * jokeLabel;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"embedCollection"]){
        BusesCollectionVC * busCollectionController = (BusesCollectionVC *) [segue destinationViewController];
        
        busCollectionController.busData = self.busData;
    }
    else if([segue.identifier isEqualToString:@"showFavorites"]){
        FavoritesTableViewController * favorites = (FavoritesTableViewController *) [segue destinationViewController];
        favorites.busData = self.busData;
    }
}
@end

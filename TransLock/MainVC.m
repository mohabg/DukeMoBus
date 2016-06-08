//
//  MainVC.m
//  TransLock
//
//  Created by Mohab Gabal on 6/1/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "MainVC.h"
#import "BusesCollectionVC.h"
#import "APIHandler.h"

@import CoreData;

@interface MainVC ()

@property (strong, nonatomic) IBOutlet UILabel * jokeLabel;
@property (strong, nonatomic) APIHandler * handler;

@end

@implementation MainVC

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.allowedBusIDs = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"chosenBusIDs.archive"]];
        self.busIDsToNames = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"busIDsToNames.archive"]];
        self.handler = [[APIHandler alloc] init];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([self.allowedBusIDs count] == 0){
        [self performSegueWithIdentifier:@"EditBuses" sender:self];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"embedCollection"]){
        BusesCollectionVC * busCollectionController = (BusesCollectionVC *) [segue destinationViewController];
        busCollectionController.allowedBusIDs = self.allowedBusIDs;
        busCollectionController.busIDsToNames = self.busIDsToNames;
    }
    BOOL savingChosenBuses = [NSKeyedArchiver archiveRootObject:self.allowedBusIDs toFile:[self getArchivePathUsingString:(@"chosenBusIDs.archive")]];
    BOOL savingBusIDMap = [NSKeyedArchiver archiveRootObject:self.busIDsToNames toFile:[self getArchivePathUsingString:@"busIDsToNames.archive"]];
}

-(NSString *)getArchivePathUsingString:(NSString *)path{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    
}
@end

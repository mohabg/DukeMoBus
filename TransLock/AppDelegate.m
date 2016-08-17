//
//  AppDelegate.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"
#import "APIHandler.h"
#import "LocationHandler.h"
#include <stdlib.h>

@interface AppDelegate ()

@property (strong, nonatomic) BusData * busData;
@property (strong, nonatomic) LocationHandler * locationHandler;
@property (strong, nonatomic) UIScrollView * movingBackground;
@property (strong, nonatomic) UIImageView * backgroundImageView;
@property (strong, nonatomic) NSArray<UIImage *> * backgroundImages;
@property (strong, nonatomic) NSMutableArray * usedBackgroundImages;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.locationHandler = [[LocationHandler alloc] init];
    [self.locationHandler start];
    
    [self createBackground];

    UINavigationController * rootNavController = (UINavigationController *) self.window.rootViewController;
    MainVC * rootController = (MainVC *) rootNavController.topViewController;
    
    self.busData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"busData.archive"]];
    
    if(!self.busData){
        self.busData = [[BusData alloc] init];
    }

    rootController.busData = self.busData;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateBackground) name:@"Background Image Set" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNearbyBusStops:) name:@"Location Received" object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL savingBusData = [NSKeyedArchiver archiveRootObject:self.busData toFile:[self getArchivePathUsingString:(@"busData.archive")]];
    if(!savingBusData){
        NSLog(@"Error Saving Bus Data");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSString *)getArchivePathUsingString:(NSString *)path{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
}


#pragma mark - Background Slide Show

-(void)createBackground{
        self.usedBackgroundImages = [NSMutableArray array];
        self.backgroundImages = [self createBackgroundImages];
        self.backgroundImageView = [[UIImageView alloc] init];
        
        self.movingBackground = [[UIScrollView alloc] initWithFrame:self.window.frame];
        self.movingBackground.userInteractionEnabled = NO;
        UIImage * backgroundImage = [self getNewBackgroundImage];

        [self.movingBackground addSubview:self.backgroundImageView];
        [self.window addSubview:self.movingBackground];
        [self setBackgroundImage:backgroundImage];
}

-(void)animateBackground{
        CGFloat actualImageEndPoint = self.movingBackground.contentSize.width - self.window.frame.size.width;
        
        [UIView animateWithDuration:25.0 animations:^{
            
            self.movingBackground.contentOffset = CGPointMake(actualImageEndPoint, 0);
            
        } completion:^(BOOL finished) {
            
            [self.movingBackground setContentOffset:CGPointMake(0, 0) animated:NO];
            UIImage * backgroundImage = [self getNewBackgroundImage];
            [UIView transitionWithView:self.movingBackground duration:1.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                [self setBackgroundImage:backgroundImage];
            } completion:nil];
        }];
}

-(void)setBackgroundImage:(UIImage *)backgroundImage{
    if(!backgroundImage) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backgroundImageView setImage:backgroundImage];
        [self.backgroundImageView setFrame:CGRectMake(self.backgroundImageView.frame.origin.x, self.backgroundImageView.frame.origin.y, backgroundImage.size.width, self.window.frame.size.height)];
        self.backgroundImageView.contentMode = UIViewContentModeCenter;
        
        self.movingBackground.contentSize = self.backgroundImageView.frame.size;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Background Image Set" object:nil];
    });
}

-(UIImage *)getNewBackgroundImage{
    if([self.usedBackgroundImages count] == [self.backgroundImages count]){
        self.usedBackgroundImages = [NSMutableArray  array];
    }
    
    UIImage * backgroundImage = [self getRandomImageFromArray:self.backgroundImages];
    
    while([self.usedBackgroundImages containsObject:backgroundImage]){
        backgroundImage = [self getRandomImageFromArray:self.backgroundImages];
    }
    [self.usedBackgroundImages addObject:backgroundImage];
    
    [self scaleImageView:self.backgroundImageView UsingImage:backgroundImage];
    
    return backgroundImage;
}

-(void)resetScrollView{
    self.movingBackground = [[UIScrollView alloc] initWithFrame:self.window.frame];
    self.movingBackground.userInteractionEnabled = NO;
    
    [self.movingBackground addSubview:self.backgroundImageView];
    [self.window addSubview:self.movingBackground];
    
    //TODO: NEED TO SCALE HEIGHT
    
}

-(UIImage *)getRandomImageFromArray:(NSArray *)backgroundImages{
    
    int randIndex = arc4random() % [backgroundImages count];
    return [backgroundImages objectAtIndex:randIndex];
    
}
-(void)scaleImageView:(UIImageView *)imageView UsingImage:(UIImage *)image{
    
    [imageView setFrame:CGRectMake(0, 0, imageView.image.size.width, self.window.frame.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(NSArray<UIImage *> *)createBackgroundImages{
    NSMutableArray * images = [NSMutableArray array];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Resources" ofType:@"plist"];
    NSDictionary * resources = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray * imageNames = [resources objectForKey:@"ImageNames"];
    for(NSString * imageName in imageNames){
        UIImage * backgroundImage = [UIImage imageNamed:imageName];
        [images addObject:backgroundImage];
    }
    return images;
}


#pragma mark - Loading Data

-(void)loadNearbyBusStops:(NSNotification *)notification{
    self.busData.userLatitude = self.locationHandler.latitude;
    self.busData.userLongitude = self.locationHandler.longitude;
    NSString * lat = self.locationHandler.latitude;
    NSString * lng = self.locationHandler.longitude;
    
    lat = @"36.005144";
    lng = @"-78.944213";

    //WARNING: CASES MAY OCCUR WHERE USER CHOOSES A BUS BEFORE STOPS ARE LOADED
    
    [APIHandler parseJsonWithRequest:[APIHandler createBusStopRequestWithLatitude:lat Longitude:lng] CompletionBlock:^(NSDictionary * json) {
        
        //Load Bus Stops In Area
        NSArray * dataArr = [json objectForKey:@"data"];
        for(int i = 0; i < [dataArr count]; i++){
            
            BusStop * busStop = [[BusStop alloc] init];
            [busStop loadFromDictionary: [dataArr objectAtIndex:i] ];
            
            [self.busData addNearbyBusStop:busStop];
        }
    }];
}
@end

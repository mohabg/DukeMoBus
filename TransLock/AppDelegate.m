//
//  AppDelegate.m
//  TransLock
//
//  Created by Mohab Gabal on 5/31/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"
#import "BusesTVC.h"
#import "APIHandler.h"
#include <stdlib.h>

@interface AppDelegate ()

@property (strong, nonatomic) BusData * busData;
@property (strong, nonatomic) UIScrollView * movingBackground;
@property (strong, nonatomic) UIImageView * backgroundImageView;
@property (strong, nonatomic) NSArray<UIImage *> * backgroundImages;
@property (strong, nonatomic) NSMutableArray * usedBackgroundImages;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.usedBackgroundImages = [NSMutableArray array];
    self.backgroundImages = [self createBackgroundImages];
    self.backgroundImageView = [[UIImageView alloc] init];
    
   // [self resetScrollView];
    self.movingBackground = [[UIScrollView alloc] initWithFrame:self.window.frame];
    self.movingBackground.userInteractionEnabled = NO;
    
    [self.movingBackground addSubview:self.backgroundImageView];
    [self.window addSubview:self.movingBackground];
    
    UIImage * backgroundImage = [self getNewBackgroundImage];
    [self setBackgroundImage:backgroundImage];

    UINavigationController * rootNavController = (UINavigationController *) self.window.rootViewController;
    MainVC * rootController = (MainVC *) rootNavController.topViewController;
    self.busData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"busData.archive"]];
    
    if(!self.busData){
        self.busData = [[BusData alloc] init];
    }
    rootController.busData = self.busData;
    
    return YES;
}


-(void)animateBackground{
    
   // CGFloat actualImageEndPoint = self.backgroundImageView.frame.size.width - [self adjustToScale:self.backgroundImageView] - self.window.frame.size.width;
    
    CGFloat actualImageEndPoint = self.movingBackground.contentSize.width - self.window.frame.size.width;
    //self.movingBackground.contentOffset = CGPointMake(0, 0);
    [UIView animateWithDuration:25.0 animations:^{
        
         self.movingBackground.contentOffset = CGPointMake(actualImageEndPoint, 0);
        
    } completion:^(BOOL finished) {
      //  [self resetScrollView];
        
        [self.movingBackground setContentOffset:CGPointMake(0, 0) animated:NO];
        UIImage * backgroundImage = [self getNewBackgroundImage];
        [UIView transitionWithView:self.movingBackground duration:1.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
            [self setBackgroundImage:backgroundImage];
        } completion:^(BOOL finished){
            
            [self animateBackground];
        }];
    }];
}

-(void)setBackgroundImage:(UIImage *)backgroundImage{
    
    [self.backgroundImageView setImage:backgroundImage];
    [self.backgroundImageView setFrame:CGRectMake(self.backgroundImageView.frame.origin.x, self.backgroundImageView.frame.origin.y, backgroundImage.size.width, self.window.frame.size.height)];
    self.backgroundImageView.contentMode = UIViewContentModeCenter;
    
    self.movingBackground.contentSize = self.backgroundImageView.frame.size;
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
    
    //NEED TO SCALE HEIGHT
    
    //CGFloat actualImageStartPoint = [self adjustToScale:self.backgroundImageView];
   // self.movingBackground.contentSize = self.backgroundImageView.image.size;
    //self.movingBackground.contentOffset = CGPointMake(actualImageStartPoint, 0);
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

- (CGFloat)adjustToScale:(UIImageView *)backgroundImageView {
    float widthRatio = backgroundImageView.bounds.size.width / backgroundImageView.image.size.width;
    float heightRatio = backgroundImageView.bounds.size.height / backgroundImageView.image.size.height;
    float scale = MIN(widthRatio, heightRatio);
    float imageWidth = scale * backgroundImageView.image.size.width;
    
    CGFloat actualImageStartPoint = (backgroundImageView.frame.size.width - imageWidth) / 2;
    return actualImageStartPoint;
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
        @throw [NSException exceptionWithName:@"Error Saving" reason:@"Could Not Save Bus Data" userInfo:nil];
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

@end

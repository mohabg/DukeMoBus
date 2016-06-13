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

@interface AppDelegate ()

@property (strong, nonatomic) BusData * busData;
@property (strong, nonatomic) dispatch_group_t group;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController * rootNavController = (UINavigationController *) self.window.rootViewController;
    MainVC * rootController = (MainVC *) rootNavController.topViewController;
    self.busData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getArchivePathUsingString:@"busData.archive"]];
    if(!self.busData){
        self.busData = [[BusData alloc] init];
    }
    rootController.busData = self.busData;
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
        @throw [NSException exceptionWithName:@"Error Saving" reason:@"Could Not Save Bus Data" userInfo:nil];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //TODO: RELOAD DATA
    
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

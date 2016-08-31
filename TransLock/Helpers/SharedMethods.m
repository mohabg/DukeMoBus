//
//  SharedMethods.m
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import "SharedMethods.h"

@implementation SharedMethods

+(UIActivityIndicatorView *)createAndCenterLoadingIndicatorInView:(UIView *)view{
    
    UIActivityIndicatorView * loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.layer.cornerRadius = 05;
    
    loadingIndicator.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    [loadingIndicator setColor:[UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0]];
    
    loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    loadingIndicator.transform = CGAffineTransformMakeScale(3.5, 3.5);
    loadingIndicator.hidesWhenStopped = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [view addSubview:loadingIndicator];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:loadingIndicator
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:loadingIndicator
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    });
    
    return loadingIndicator;
}


+(NSString *)getArchivePathUsingString:(NSString *)path{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:path];
    
}

+(NSString *)walkingTimeString:(NSString *)walkTime{
    NSInteger walkTimeInt = [walkTime integerValue];
    
    if(walkTimeInt <= 1){
        
        return @"Arriving Now";
    }
    return [NSString stringWithFormat:@"%@ mins", walkTime];
}

+(NSString *)getUserFriendlyStopName:(NSString *) stopName{
    
    NSMutableString * nameWithoutParantheses = [[NSMutableString alloc] init];
    for(int i = 0; i < stopName.length; i++){
        if([stopName characterAtIndex:i] == '('){
            break;
        }
        [nameWithoutParantheses appendFormat:@"%c", [stopName characterAtIndex:i]];
    }
    return nameWithoutParantheses;
}

+(NSString *)getUserFriendlyBusTitle:(NSString *)busTitle{
    
    NSInteger colonOrSpace;
    
    for(int i = 0; i < busTitle.length; i++){
        
        NSString * charString = [NSString stringWithFormat:@"%c", [busTitle characterAtIndex:i]];
        
        if([charString isEqualToString:@":"] || [charString isEqualToString:@" "]){
            
            colonOrSpace = i;
            break;
        }
    }
    
    return [busTitle substringToIndex:colonOrSpace];
}


@end

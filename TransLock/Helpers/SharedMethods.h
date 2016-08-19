//
//  SharedMethods.h
//  TransLock
//
//  Created by Mohab Gabal on 8/18/16.
//  Copyright © 2016 Mohab Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SharedMethods : NSObject

+(UIActivityIndicatorView *)createAndCenterLoadingIndicatorInView:(UIView *)view;

+(NSString *)getArchivePathUsingString:(NSString *)path;

@end


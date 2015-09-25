//
//  TXFrontAccess.h
//  FrontAccessDev
//
//  Created by 栗田 哲郎 on 2015/09/24.
//  Copyright (c) 2015年 tkurita. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TXFrontAccess : NSObject

+ (TXFrontAccess *)frontAccessForFrontmostApp;
+ (TXFrontAccess *)frontAccessWithRunningApplication:(NSRunningApplication *)runningApp;
+ (TXFrontAccess *)frontAccessWithBundleIdentifier:(NSString *)bundleIdentifier;

- (NSURL *)documentURL; /* required GUI Scripting */
- (AXUIElementRef)mainWindow; /* required GUI Scripting */

- (BOOL)isCurrentApplication;
- (NSString *)bundleIdentifier;
- (void)setupErrorMessage:(NSString *)message number:(AXError)errnumber;

@property NSRunningApplication *targetApplication;
@property (assign) AXUIElementRef axApplication;
@property NSError *error;

@end

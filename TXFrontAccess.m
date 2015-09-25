//
//  TXFrontAccess.m
//  FrontAccessDev
//
//  Created by 栗田 哲郎 on 2015/09/24.
//  Copyright (c) 2015年 tkurita. All rights reserved.
//

#import "TXFrontAccess.h"

@implementation TXFrontAccess


- (void)dealloc {
    CFRelease(_axApplication);
}

NSString *messageForAXError(AXError error)
{
    switch (error) {
        case kAXErrorFailure:
            return @"A system error occurred";
        case kAXErrorIllegalArgument:
            return @"An illegal argument was passed to the function.";
        case kAXErrorInvalidUIElement:
            return @"The AXUIElementRef passed to the function is invalid.";
        case kAXErrorInvalidUIElementObserver:
            return @"The AXObserverRef passed to the function is not a valid observer.";
        case kAXErrorCannotComplete:
            return @"The function cannot complete because messaging failed in some way or because the application with which the function is communicating is busy or unresponsive.";
        case kAXErrorAttributeUnsupported:
            return @"The attribute is not supported by the AXUIElementRef.";
        case kAXErrorActionUnsupported:
            return @"The action is not supported by the AXUIElementRef.";
        case kAXErrorNotificationUnsupported:
            return @"The notification is not supported by the AXUIElementRef.";
        case kAXErrorNotImplemented:
            return @"Indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API).";
        case kAXErrorNotificationAlreadyRegistered:
            return @"This notification has already been registered for.";
        case kAXErrorNotificationNotRegistered:
            return @"Indicates that a notification is not registered yet.";
        case kAXErrorAPIDisabled:
            return @"The accessibility API is disabled.";
        case kAXErrorNoValue:
            return @"The requested value or AXUIElementRef does not exist.";
        case kAXErrorParameterizedAttributeUnsupported:
            return @"The parameterized attribute is not supported by the AXUIElementRef.";
        case kAXErrorNotEnoughPrecision:
            return @"Not enough precision.";
        default:
            break;
    }
    return @"";
}

void AXErrorLog(NSString *msg, AXError err)
{
    NSLog(@"%@ reason:%@", msg, messageForAXError(err));
}

+ (TXFrontAccess *)frontAccessWithRunningApplication:(NSRunningApplication *)runningApp
{
   	TXFrontAccess *newobj = [[self class] new];
	newobj.targetApplication = runningApp;
    newobj.axApplication = AXUIElementCreateApplication([runningApp processIdentifier]);
	return newobj;
}

+ (TXFrontAccess *)frontAccessForFrontmostApp
{
    NSRunningApplication *front_app = [[NSWorkspace sharedWorkspace] frontmostApplication];
    return [self frontAccessWithRunningApplication:front_app];
}

+ (TXFrontAccess *)frontAccessWithBundleIdentifier:(NSString *)bundleIdentifier
{
    NSArray *apps = [NSRunningApplication
                     runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if (apps.count) {
        return [self frontAccessWithRunningApplication:[apps lastObject]];
    }
    return nil;
}

- (void)setupErrorMessage:(NSString *)message number:(AXError)errnumber
{
    NSString *msg = [NSString stringWithFormat:
                     NSLocalizedStringFromTable(message, @"TXFrontAccessLocalizedStrings", @""),
                     _targetApplication.localizedName];
    self.error = [NSError errorWithDomain:@"FrontAccessErrorDomain"
                                     code:errnumber
                                 userInfo:@{NSLocalizedDescriptionKey:msg}];
}

- (NSURL *)documentURL
{
    AXUIElementRef target_window = [self mainWindow];
    if (!target_window) return nil;
    
    CFTypeRef value = NULL;
    AXError err = AXUIElementCopyAttributeValue(target_window,
                                (CFStringRef)NSAccessibilityDocumentAttribute,
                                                &value);
    if (kAXErrorSuccess != err ) {
        #if DEBUG
        AXErrorLog(@"Failed to get AXDocument.", err);
        #endif
        [self setupErrorMessage:@"Can't get a file reference for the front window of the process : %@"
                         number:err];
        return nil;
    }
    return [NSURL URLWithString:CFBridgingRelease(value)];
}

- (AXUIElementRef)mainWindow
{
    CFTypeRef value = NULL;
     AXError err = AXUIElementCopyAttributeValue(_axApplication,
                                (CFStringRef)NSAccessibilityMainWindowAttribute,
                                                &value);

    if (kAXErrorSuccess != err ) {
        #if DEBUG
        AXErrorLog(@"Failed to get Main Winow.", err);
        #endif
        [self setupErrorMessage:@"Cant' find a main window of the process : %@"
                         number:err];
        return nil;
    }
    return value;
}

- (BOOL)isCurrentApplication
{
    return [_targetApplication isEqual:
                [NSRunningApplication currentApplication]];
}

- (NSString *)bundleIdentifier
{
    return  _targetApplication.bundleIdentifier;
}

@end

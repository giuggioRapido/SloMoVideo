//
//  PasscodeServices.m
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "PasscodeServices.h"
@import LocalAuthentication;
#import "<#header#>"

@implementation PasscodeServices

+ (BOOL)touchIDIsAvailable
{
    return YES;
}


+ (BOOL)passcodeEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PasscodeEnabled"]) {
        return YES;
    }
    
    else {
        return NO;
    }
}

+ (BOOL)touchIDEnabled
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TouchIDEnabled"]) {
        return YES;
    }
    
    else {
        return NO;
    }
}

+ (void)storePasscodeInKeychain:(NSString*)passcode
{
    [[NSUserDefaults standardUserDefaults] setObject:passcode forKey:@"passcode"];
}

+ (BOOL)isPasscodeValid:(NSString*)passcodeToCheck
{
    if (passcodeToCheck == [[NSUserDefaults standardUserDefaults] objectForKey:@"passcode"]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)promptForTouchID
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"String explaining why app needs authentication";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    NSLog(@"success");
                                } else {
                                    NSLog(@"something went wrong");
                                }
                            }];
    } else {
        // Could not evaluate policy; look at authError and present an appropriate message to user
    }
    
    
}

+ (void)promptForPasscodeInViewController:(id<PasscodeAlertControllerHandling>)viewController
{
    
    [viewController presentEnterPasscodeAlert];
}

@end

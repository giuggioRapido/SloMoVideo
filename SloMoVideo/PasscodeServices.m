//
//  PasscodeServices.m
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "PasscodeServices.h"
@import LocalAuthentication;

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

+ (void)storePasscodeInKeychain:(NSString*)passcode
{
    [[NSUserDefaults standardUserDefaults] setObject:passcode forKey:@"passcode"];
}

+ (BOOL)passcodeValid:(NSString*)passcodeToCheck
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
    
}

+ (void)promptForPasscode
{
    
}

@end

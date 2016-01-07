//
//  PasscodeServices.m
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "PasscodeServices.h"
@import LocalAuthentication;
#import "UIAlertController+PasscodeAlertControllers.h"
#import "WindowedAlertController.h"

@implementation PasscodeServices

NSString *firstPasscode;
NSString *secondPasscode;

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


/// Ask the user if they want to enable a passcode for the app. If not, we set a bool in defaults that passcode isn't enabled.
/// If yes, we call presentCreatePasscodeAlert.
+ (void)promptForPasscode
{
    WindowedAlertController *alert = [WindowedAlertController alertToEnablePasscodeWithCancelBehavior:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PasscodeEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } andYesBehavior:^{
        [self presentCreatePasscodeAlert];
        
    }];
    
    [alert show];
}

/// Ask the user to type in desired passcode. If user selects Cancel, bring them back to the first alert. When they enter a passcode and select Confirm, call presentConfirmPasscodeAlert.
+ (void)presentCreatePasscodeAlert
{
    
    __block WindowedAlertController *alert = [WindowedAlertController alertToCreatePasscodeWithCancelBehavior:^{
        [self presentEnablePasscodeAlert];
        
    } andConfirmBehavior:^{
        firstPasscode = alert.textFields[0].text;
        [self presentConfirmPasscodeAlert];
        
    }];
    
    alert.textFields[0].delegate = self;
    
    [alert show];
}

/// Prompt the user to type the passcode again to confirm. If the passcodes do not match, call presentNonmatchingPasscodesAlert.
/// If they do match, handle in Passcode Services and call presentEnableTouchIDAlert.
+ (void)presentConfirmPasscodeAlert
{
    __block WindowedAlertController *alert = [WindowedAlertController alertToConfirmPasscodeWithCancelBehavior:^{
        [self presentEnablePasscodeAlert];
        
    } andConfirmBehavior:^{
        secondPasscode = alert.textFields[0].text;
        if ([self passcodesMatch]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PasscodeEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([PasscodeServices touchIDIsAvailable]) {
                [self presentEnableTouchIDAlert];
            }
        }
        else {
            [self presentNonmatchingPasscodesAlert];
        }
        
    }];
    
    
    alert.textFields[0].delegate = self;
    
    [alert show];
}

+ (BOOL)passcodesMatch
{
    if (firstPasscode == secondPasscode) {
        [PasscodeServices storePasscodeInKeychain:secondPasscode];
        firstPasscode = nil;
        secondPasscode = nil;
        
        return YES;
    }
    else {
        firstPasscode = nil;
        secondPasscode = nil;
        
        return NO;
    }
}

+ (void)presentNonmatchingPasscodesAlert
{
    
    __block WindowedAlertController *alert = [WindowedAlertController alertThatPasscodesDoNotMatchWithCancelBehavior:^{
        [self presentEnablePasscodeAlert];
        
    } andConfirmBehavior:^{
        firstPasscode = alert.textFields[0].text;
        [self presentConfirmPasscodeAlert];
        
    }];
    
    alert.textFields[0].delegate = self;
    
    [alert show];
}

+ (void)presentEnableTouchIDAlert
{
    WindowedAlertController *alert = [WindowedAlertController alertToEnableTouchIDWithCancelBehavior:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TouchIDEnabled"];
        
    } andYesBehavior:^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TouchIDEnabled"];
        
    }];
    [alert show];
}

#pragma mark - UITextFieldDelegate

/// In this method, we keep track of the content of the texfield at any given moment so that we can enable/disable buttons (i.e. only enable Confirm if the textfield count is >0)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    UIResponder *responder = textField;
    Class uiacClass = [UIAlertController class];
    while (![responder isKindOfClass: uiacClass])
    {
        responder = [responder nextResponder];
    }
    UIAlertController *alert = (UIAlertController*) responder;
    UIAlertAction *setPassword  = [alert.actions objectAtIndex: 1];
    
    if (newString.length == 0) {
        setPassword.enabled = NO;
        return YES;
    }
    else {
        setPassword.enabled = YES;
        return YES;
    }
}





@end

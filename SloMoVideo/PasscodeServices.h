//
//  PasscodeServices.h
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

/// This class handles passcode validation and passcode-related alert presentation

#import <Foundation/Foundation.h>
@import UIKit;

@interface PasscodeServices : NSObject <UITextFieldDelegate>

@property BOOL shouldPromptForPasscodeCreation;

+ (BOOL)passcodeEnabled;
+ (BOOL)touchIDEnabled;
+ (BOOL)touchIDIsAvailable;
+ (void)storePasscodeInKeychain:(NSString*)passcode;
+ (BOOL)isValidPasscode:(NSString*)passcodeToCheck;
+ (void)promptForTouchID;
+ (void)promptForPasscode;
+ (void)presentCreatePasscodeAlert;
+ (void)presentConfirmPasscodeAlert;
+ (void)presentNonmatchingPasscodesAlert;
+ (void)presentEnableTouchIDAlert;
+ (void)presentEnablePasscodeAlert;


@end

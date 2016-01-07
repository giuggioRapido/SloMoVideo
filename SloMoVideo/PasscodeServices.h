//
//  PasscodeServices.h
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasscodeServices : NSObject <UITextFieldDelegate>

@property BOOL shouldPromptForPasscodeCreation;

+ (BOOL)passcodeEnabled;
+ (BOOL)touchIDEnabled;
+ (BOOL)touchIDIsAvailable;
+ (void)storePasscodeInKeychain:(NSString*)passcode;
+ (BOOL)isPasscodeValid:(NSString*)passcodeToCheck;
+ (void)promptForTouchID;
+ (void)promptForPasscode;
+ (void)presentCreatePasscodeAlert;
+ (void)presentConfirmPasscodeAlert;
+ (void)presentNonmatchingPasscodesAlert;
+ (void)presentEnableTouchIDAlert;


@end

//
//  PasscodeServices.h
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasscodeAlertControllerHandling.h"
@import UIKit;

@interface PasscodeServices : NSObject

@property BOOL shouldPromptForPasscodeCreation;

+ (BOOL)passcodeEnabled;
+ (BOOL)touchIDIsAvailable;
+ (void)storePasscodeInKeychain:(NSString*)passcode;
+ (BOOL)isPasscodeValid:(NSString*)passcodeToCheck;
+ (BOOL)touchIDEnabled;
+ (void)promptForPasscodeInViewController:(id<PasscodeAlertControllerHandling>)viewController;
+ (void)promptForTouchID;


@end

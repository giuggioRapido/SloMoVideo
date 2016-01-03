//
//  UIAlertController+UIAlertController_PasscodeAlerts.h
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (UIAlertController_PasscodeAlerts)

+ (UIAlertController*)enablePasscodeAlertWithNoBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;
+ (UIAlertController*)passcodeCreationAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock;
+ (UIAlertController*)passcodeConfirmationAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock;
+ (UIAlertController*)nonmatchingPasscodesAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock;
+ (UIAlertController*)enableTouchIDAlertWithNoBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;

@end

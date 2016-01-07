//
//  UIAlertController+PasscodeAlertControllers.h
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (PasscodeAlertControllers)

+ (instancetype)enablePasscodeAlertWithNoBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;

+ (instancetype)passcodeCreationAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock;

+ (instancetype)passcodeConfirmationAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock;

+ (instancetype)nonmatchingPasscodesAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock;

+ (instancetype)enableTouchIDAlertWithNoBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;

+ (instancetype)enterPasscodeAlertWithEnterBehavior:(void(^)())enterBlock;



@end

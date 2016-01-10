//
//  UIAlertController+PasscodeAlertControllers.h
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

/// This catgory provides factory methods for all alert controllers designed for the passcode and TouchID feature.
/// The methods take as arguments blocks that provide the functionalty for an alert's buttons. 

#import <UIKit/UIKit.h>

@interface UIAlertController (PasscodeAlertControllers)

+ (instancetype)alertToEnablePasscodeWithCancelBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;

+ (instancetype)alertToCreatePasscodeWithCancelBehavior:(void(^)())cancelBlock andConfirmBehavior:(void(^)())confirmBlock;

+ (instancetype)alertToConfirmPasscodeWithCancelBehavior:(void(^)())cancelBlock andConfirmBehavior:(void(^)())confirmBlock;

+ (instancetype)alertThatPasscodesDoNotMatchWithCancelBehavior:(void(^)())cancelBlock andConfirmBehavior:(void(^)())confirmBlock;

+ (instancetype)alertToEnableTouchIDWithCancelBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;

+ (instancetype)alertToEnterPasscodeWithBehavior:(void(^)())actionBlock;



@end

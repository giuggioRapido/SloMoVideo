//
//  UIAlertController+UIAlertController_PasscodeAlerts.m
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "UIAlertController+UIAlertController_PasscodeAlerts.h"

@implementation UIAlertController (UIAlertController_PasscodeAlerts)

+ (UIAlertController*)enablePasscodeAlertWithNoBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock
{
    UIAlertController *passcodePreferenceAlert = [UIAlertController alertControllerWithTitle:@"Would you like to create a passcode?"
                                                                                     message:@"This can be changed in Settings later."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
                                                         if (noBlock) {
                                                             noBlock();
                                                         }
                                                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PasscodeEnabled"];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                     }];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          if (yesBlock) {
                                                              yesBlock();
                                                          }
                                                      }];
    
    [passcodePreferenceAlert addAction:noAction];
    [passcodePreferenceAlert addAction:yesAction];
    passcodePreferenceAlert.preferredAction = yesAction;
    
    return passcodePreferenceAlert;
}


+ (UIAlertController*)passcodeCreationAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock
{
    UIAlertController *passcodeCreationAlert = [UIAlertController alertControllerWithTitle:@"Enter a passcode"
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [passcodeCreationAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             if (cancelBlock) {
                                                                 cancelBlock();
                                                             }
                                                         }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Continue"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              if (confirmBlock) {
                                                                  confirmBlock();
                                                              }
                                                          }];
    
    [passcodeCreationAlert addAction:cancelAction];
    [passcodeCreationAlert addAction:confirmAction];
    passcodeCreationAlert.preferredAction = confirmAction;
    confirmAction.enabled = NO;
    
    return passcodeCreationAlert;
}


+ (UIAlertController*)passcodeConfirmationAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock
{
    UIAlertController *passcodeConfirmationAlert = [UIAlertController alertControllerWithTitle:@"Re-enter passcode to confirm"
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    [passcodeConfirmationAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             if (cancelBlock) {
                                                                 cancelBlock();
                                                             }
                                                         }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              if (confirmBlock) {
                                                                  confirmBlock();
                                                              }
                                                              
                                                          }];
    
    
    [passcodeConfirmationAlert addAction:cancelAction];
    [passcodeConfirmationAlert addAction:confirmAction];
    passcodeConfirmationAlert.preferredAction = confirmAction;
    confirmAction.enabled = NO;
    
    return passcodeConfirmationAlert;
}

+ (UIAlertController*)nonmatchingPasscodesAlertWithConfirmBehavior:(void(^)())confirmBlock andCancelBehavior:(void(^)())cancelBlock
{
    UIAlertController *nonmatchingPasscodesAlert = [UIAlertController alertControllerWithTitle:@"Passcodes do not match"
                                                                                       message:@"Enter a passcode"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    [nonmatchingPasscodesAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             if(cancelBlock){
                                                                 cancelBlock();
                                                             }
                                                         }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Continue"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              if(confirmBlock){
                                                                  confirmBlock();
                                                              }
                                                          }];
    
    [nonmatchingPasscodesAlert addAction:cancelAction];
    [nonmatchingPasscodesAlert addAction:confirmAction];
    nonmatchingPasscodesAlert.preferredAction = confirmAction;
    confirmAction.enabled = NO;
    
    return nonmatchingPasscodesAlert;
}

+ (UIAlertController*)enableTouchIDAlertWithNoBehavior:(void(^)())noBlock andYesBehavior:(void(^)())yesBlock;
{
    UIAlertController *enableTouchIDAlert = [UIAlertController alertControllerWithTitle:@"Enable TouchID?"
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action) {
                                                         if (noBlock) {
                                                             noBlock();
                                                         }
                                                     }];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          if (yesBlock) {
                                                              yesBlock();
                                                          }
                                                      }];
    
    [enableTouchIDAlert addAction:noAction];
    [enableTouchIDAlert addAction:yesAction];
    enableTouchIDAlert.preferredAction = yesAction;
    return enableTouchIDAlert;
}

+ (UIAlertController*)enterPasscodeAlertWithEnterBehavior:(void(^)())enterBlock
{
    UIAlertController *enterPasscodeAlert = [UIAlertController alertControllerWithTitle:@"Enter passcode"
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *enterAction = [UIAlertAction actionWithTitle:@"Enter"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            if (enterBlock) {
                                                                enterBlock();
                                                            }
                                                        }];
    [enterPasscodeAlert addAction:enterAction];
   
    return enterPasscodeAlert;
}

@end

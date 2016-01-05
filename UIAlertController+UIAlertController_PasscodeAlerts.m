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
                                                          //[self createPassword];
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
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //[self promptPasswordCreation];
                                                             if (cancelBlock) {
                                                                 cancelBlock();
                                                             }
                                                         }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //self.password = passCodeCreationAlert.textFields[0].text;
                                                              //[self confirmPassword];
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
    UIAlertController *passcodeConfirmationAlert = [UIAlertController alertControllerWithTitle:@"Type passcode again to confirm"
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    [passcodeConfirmationAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
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
                                                              
                                                              //                                                              if (passcodeConfirmationAlert.textFields[0].text == self.password) {
                                                              //                                                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PasscodeEnabled"];
                                                              //                                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                              //
                                                              //                                                                  BOOL hasTouchID = NO;
                                                              //                                                                  // if the LAContext class is available
                                                              //                                                                  if ([LAContext class]) {
                                                              //                                                                      LAContext *context = [LAContext new];
                                                              //                                                                      NSError *error = nil;
                                                              //                                                                      hasTouchID = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
                                                              //                                                                  }
                                                              //
                                                              //                                                                  if (hasTouchID) {
                                                              //                                                                      //[self promptForTouchID];
                                                              //                                                                  }
                                                              //                                                              }
                                                              //
                                                              //                                                              else {
                                                              //                                                                  //[self presentUnequalPasswordsAlert];
                                                              //                                                              }
                                                              
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
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //[self promptPasswordCreation];
                                                             if(cancelBlock){
                                                                 cancelBlock();
                                                             }
                                                         }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //self.password = passCodeCreationAlert.textFields[0].text;
                                                              //[self confirmPassword];
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
                                                         //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TouchIDEnabled"];
                                                     }];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          if (yesBlock) {
                                                              yesBlock();
                                                          }
                                                          //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TouchIDEnabled"];
                                                      }];
    
    [enableTouchIDAlert addAction:noAction];
    [enableTouchIDAlert addAction:yesAction];
    enableTouchIDAlert.preferredAction = yesAction;
    return enableTouchIDAlert;
}
@end

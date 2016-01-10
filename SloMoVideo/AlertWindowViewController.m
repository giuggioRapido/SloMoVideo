//
//  AlertWindowViewController.m
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "AlertWindowViewController.h"
#import "WindowedAlertController.h"

@implementation AlertWindowViewController


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    /// In this method, we keep track of the content of the texfield at any given moment so that we can enable/disable buttons (i.e. only enable Confirm if the textfield count is >0)
   
    NSString *newString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    UIResponder *responder = textField;
    Class wacClass = [WindowedAlertController class];
    while (![responder isKindOfClass: wacClass]) {
        responder = [responder nextResponder];
    }
    UIAlertController *alert = (UIAlertController*) responder;
    UIAlertAction *setPassword  = [alert.actions objectAtIndex: alert.actions.count-1];
    
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

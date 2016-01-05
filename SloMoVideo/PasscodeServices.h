//
//  PasscodeServices.h
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasscodeServices : NSObject

@property BOOL shouldPromptForPasscodeCreation;

+ (BOOL)passcodeEnabled;
+ (BOOL)touchIDIsAvailable;
+ (void)storePasscodeInKeychain:(NSString*)passcode;
+ (BOOL)passcodeValid:(NSString*)passcodeToCheck;

@end

//
//  PasscodeServices.m
//  SloMoVideo
//
//  Created by Chris on 1/3/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "PasscodeServices.h"
@import LocalAuthentication;

@implementation PasscodeServices

+ (BOOL)touchIDIsAvailable {
    return YES;
}

@end

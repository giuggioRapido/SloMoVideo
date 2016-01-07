//
//  PasscodeAlertControllerHandling.h
//  SloMoVideo
//
//  Created by Chris on 1/5/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PasscodeAlertControllerHandling <NSObject>

@required
- (void)presentEnterPasscodeAlert;

@optional

- (void)presentEnablePasscodeAlert;
- (void)presentConfirmPasscodeAlert;
- (BOOL)passcodesMatch;
- (void)presentNonmatchingPasscodesAlert;
- (void)presentEnableTouchIDAlert;

@end

//
//  WindowedAlertController.h
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertController+UIAlertController_PasscodeAlerts.h"

@interface WindowedAlertController : UIAlertController

@property (nonatomic, strong) UIWindow *alertWindow;


- (void)show;
- (void)show:(BOOL)animated;

@end

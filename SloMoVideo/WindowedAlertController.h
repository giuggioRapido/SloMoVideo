//
//  WindowedAlertController.h
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

/// This subclass of UIAlertController creates alert contoller objects that are presented in their own window.
/// This allows for the alerts to be presented "globally", so to speak, i.e. created and presented over and divorced of any given view controller currently being used.
/// This keeps our view controllers (e.g. CameraViewController, PlaybackViewController) cleaner because they don't need to handle any creation, configuration, or text field delegation for an alert.

/// Instead of present WindowedAlertControllers with presentViewController... use the -show methods instead, which set up the window for the alert controller and sets its rootVC to an AlertWindowViewController object, which handles text field delegation for alerts with textfields. 

#import <UIKit/UIKit.h>

@interface WindowedAlertController : UIAlertController

@property (nonatomic, strong) UIWindow *alertWindow;

- (void)show:(BOOL)animated completionHandler:(void(^)())handler;
- (void)show:(BOOL)animated;

@end

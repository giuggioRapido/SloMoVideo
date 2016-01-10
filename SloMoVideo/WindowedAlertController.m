//
//  WindowedAlertController.m
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import "WindowedAlertController.h"
#import "AlertWindowViewController.h"

@implementation WindowedAlertController

- (void)show {
    [self show:YES];
}

- (void)show:(BOOL)animated {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[AlertWindowViewController alloc] init];
    self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
    [self.alertWindow makeKeyAndVisible];
    
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)show:(BOOL)animated completionHandler:(void(^)())handler {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[AlertWindowViewController alloc] init];
    
    self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
    [self.alertWindow makeKeyAndVisible];
    
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:handler];
    
//    if (handler) {
//        handler();
//    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
        
    // Precaution to ensure window gets destroyed
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}



@end

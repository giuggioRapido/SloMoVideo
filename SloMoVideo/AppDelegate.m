//
//  AppDelegate.m
//  SloMoVideo
//
//  Created by Chris on 9/23/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "AppDelegate.h"
#import "MediaLibrary.h"
#import "PasscodeServices.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Inform the device that we want to use the device orientation.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    /// Get video files without GCD
    //[[MediaLibrary sharedLibrary] initialPullFromDocuments];
    
    /// Using async serial queue. At the moment, this seems to offer fastest launch time. Speed differences
    /// start becoming apparent around the 70 video mark.
    dispatch_queue_t mediaLibraryQueue = dispatch_queue_create("media library queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(mediaLibraryQueue, ^{
        [[MediaLibrary sharedLibrary] initialPullFromDocuments];
    });
    
    /// Using global concurrent queue
    //            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
    //            [[MediaLibrary sharedLibrary] initialPullFromDocuments];
    //         });
    
    
    /// Users have the chice to enable passcode/TouchID to make the app more private/secure. If the user has enabled these features, the app requires validation any time it launches or is brought to foreground. 
    
    /// Check if this is the app's first launch. If so, set a BOOL in the first view controller that is checked in viewDidAppear and controls whether the user is prompted to enable a passcode for the app.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [PasscodeServices presentEnablePasscodeAlert];
    }
    
    /// Else, call appropriate security method.
    /// We check that touchID is both enabled AND available (despite seeming redundancy) in case the user has disabled passcode/TouchID in their system settings. Otherwise, the user could initially set up the app while their phone passcode is on, create app-specific pascode, enable touchID, then disable phone passcode and thereby give direct access to app since it will bypass passcode entry since it thinks touch ID is enabled. 
    else {
        if ([PasscodeServices touchIDEnabled] && [PasscodeServices touchIDIsAvailable]) {
            [PasscodeServices promptForTouchID];
        }
        
        else if ([PasscodeServices passcodeEnabled]) {
            [PasscodeServices promptForPasscode];
        }
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([PasscodeServices touchIDEnabled] && [PasscodeServices touchIDIsAvailable]) {
        [PasscodeServices promptForTouchID];
    }
    
    else if ([PasscodeServices passcodeEnabled]) {
        [PasscodeServices promptForPasscode];
    }
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

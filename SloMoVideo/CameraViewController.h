//
//  CameraViewController.h
//  SloMoVideo
//
//  Created by Chris on 9/23/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewView.h"
@import Photos;
@import AVFoundation;
#import "MediaLibrary.h"
#import "UIAlertController+UIAlertController_PasscodeAlerts.h"
#import "PasscodeServices.h"
#import "PasscodeAlertControllerHandling.h"

@interface CameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate, UITextFieldDelegate, PasscodeAlertControllerHandling>


@end

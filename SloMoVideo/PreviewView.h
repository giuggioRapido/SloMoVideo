//
//  PreviewView.h
//  SloMoVideo
//
//  Created by Chris on 9/23/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface PreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end

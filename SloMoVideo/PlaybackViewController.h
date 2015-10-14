//
//  PlaybackViewController.h
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
#import "Video.h"
#import "MediaLibrary.h"

@interface PlaybackViewController : UIViewController

@property (nonatomic) Video *videoToPlay;

@end

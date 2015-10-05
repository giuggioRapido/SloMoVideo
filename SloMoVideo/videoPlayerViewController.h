//
//  videoPlayerViewController.h
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
#import "PlayerView.h"
#import "Video.h"

@interface videoPlayerViewController : UIViewController

@property (nonatomic) AVPlayer *player;
@property AVPlayerItem *playerItem;
@property AVPlayerLayer *playerLayer;
@property (nonatomic) Video *videoToPlay;

@end

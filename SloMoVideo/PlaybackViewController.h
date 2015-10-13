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

@property (nonatomic) AVPlayer *player;
@property AVPlayerItem *playerItem;
@property AVPlayerLayer *playerLayer;
@property (nonatomic) Video *videoToPlay;
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *speedButton;
@property (nonatomic) NSArray *playbackSpeedStrings;

@property (weak, nonatomic) IBOutlet UIButton *trashButton;

@end

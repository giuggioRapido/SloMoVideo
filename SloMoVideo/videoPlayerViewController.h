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

@interface videoPlayerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) AVPlayer *player;
@property AVPlayerItem *playerItem;
@property AVPlayerLayer *playerLayer;
@property (nonatomic) Video *videoToPlay;
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *speedButton;
@property (nonatomic) NSArray *playbackSpeeds;
@end

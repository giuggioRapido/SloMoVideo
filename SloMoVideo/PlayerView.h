//
//  PlayerView.h
//  SloMoVideo
//
//  Created by Chris on 10/1/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface PlayerView : UIView

@property AVPlayer *player;
@property (readonly) AVPlayerLayer *playerLayer;

@end

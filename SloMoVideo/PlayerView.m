//
//  PlayerView.m
//  SloMoVideo
//
//  Created by Chris on 10/14/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end

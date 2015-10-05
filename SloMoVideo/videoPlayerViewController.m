//
//  videoPlayerViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "videoPlayerViewController.h"

@implementation videoPlayerViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoToPlay.asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer:playerLayer];
    
    // [self.player seekToTime:kCMTimeZero];
    
    [self.player play];
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end

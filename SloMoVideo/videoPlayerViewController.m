//
//  videoPlayerViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "videoPlayerViewController.h"

@implementation videoPlayerViewController
{
    int currentSpeedIndex;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.playbackSpeeds = [NSArray arrayWithObjects:@"1x", @"2x", @"0.25x", @"0.5x", nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    currentSpeedIndex = 0;
    [self.speedButton setTitle:self.playbackSpeeds[currentSpeedIndex] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoToPlay.asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:self.playerLayer];
    
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    // NSLog(@"%i", self.playerItem.canPlaySlowForward);
    // [self.player seekToTime:kCMTimeZero];
    
    // NSLog (@"%@", NSStringFromCGRect(self.playerLayer.videoRect));
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)pressPlay:(id)sender
{
    self.PlayButton.selected = YES;
    [self.player play];
}

-(void) hideUI
{
    self.navigationController.navigationBarHidden = YES;
    self.toolbar.hidden = YES;
    self.PlayButton.hidden = YES;
}

-(void) unhideUI
{
    self.navigationController.navigationBarHidden = NO;
    self.toolbar.hidden = NO;
    self.PlayButton.hidden = NO;
}

- (IBAction)changePlaybackSpeed:(id)sender
{
    if (currentSpeedIndex == self.playbackSpeeds.count - 1) {
        currentSpeedIndex = 0;
        [self.speedButton setTitle:self.playbackSpeeds[currentSpeedIndex] forState:UIControlStateNormal];
    }
    else {
        currentSpeedIndex++;
        [self.speedButton setTitle:self.playbackSpeeds[currentSpeedIndex] forState:UIControlStateNormal];
    }
}

- (IBAction)deleteVideo:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = self.videoToPlay.stringPath;
    NSError *error = nil;
    
    
    if (![fileManager removeItemAtPath:filePath error:&error]) {
        NSLog(@"[Error] %@ (%@)", error, filePath);
    } else {
        NSLog(@"Video deleted");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


@end

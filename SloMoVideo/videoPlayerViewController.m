//
//  videoPlayerViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "videoPlayerViewController.h"

@implementation videoPlayerViewController

int currentSpeedIndex;
float playbackSpeeds[3];
static int videoPlayerViewControllerKVOContext = 0;


-(void) viewDidLoad
{
    [super viewDidLoad];
    
    /// These arrays are coordinated with the currentSpeedIndex to synchronize the playback speed button's title with the
    /// actual desired speed integer.
    
    self.playbackSpeedStrings = [NSArray arrayWithObjects:@"1x", @"2x", @"0.5x", nil];
    
    playbackSpeeds[0] = 1.0;
    playbackSpeeds[1] = 2.0;
    playbackSpeeds[2] = 0.5;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /// Reset playback speed to 1x whenever view appears and set button title appropriately.
    
    currentSpeedIndex = 0;
    [self.speedButton setTitle:self.playbackSpeedStrings[currentSpeedIndex] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoToPlay.asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.view.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    [self.view.layer addSublayer:self.playerLayer];
    
    [self addObserver:self forKeyPath:@"self.player.rate" options:NSKeyValueObservingOptionNew context:&videoPlayerViewControllerKVOContext];
    
    
    //     NSLog(@"%i", self.playerItem.canPlaySlowForward);
    //     [self.player seekToTime:kCMTimeZero];
    //
    //     NSLog (@"%@", NSStringFromCGRect(self.playerLayer.videoRect));
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.player pause];
    [self removeObserver:self forKeyPath:@"self.player.rate" context:&videoPlayerViewControllerKVOContext];
}

#pragma mark IBAction

- (IBAction)pressPlay:(id)sender
{
    if (self.player.rate != 0){
        [self.player pause];
    } else {
        if (CMTIME_COMPARE_INLINE(self.player.currentTime, ==, self.playerItem.duration)) {
            [self.player seekToTime:kCMTimeZero];
        }
        
        /// No need to call [self.player play] since setting the speed to anything other than 0 will play video.
        self.player.rate = playbackSpeeds[currentSpeedIndex];
    }
    
    //    NSLog(@"player rate: %@", [self.player valueForKey:@"rate"]);
    //    NSLog(@"can play slow: %d", [self.playerItem canPlaySlowForward]);
    //    NSLog(@"can play fast: %d", [self.playerItem canPlayFastForward]);
}


- (IBAction)changePlaybackSpeed:(id)sender
{
    /// If current index is at end of array, reset back to array index 0 in order to cycle through array.
    /// Update relevant properties. Else simply increment the array.
    /// The interior if/else clauses ensure that changing the playback rate while paused doesn't cause the video to play
    /// automatically.
    
    if (currentSpeedIndex == self.playbackSpeedStrings.count - 1) {
        currentSpeedIndex = 0;
        
        if (self.player.rate != 0) {
            self.player.rate = playbackSpeeds[currentSpeedIndex];
        }
        
        [self.speedButton setTitle:self.playbackSpeedStrings[currentSpeedIndex] forState:UIControlStateNormal];
    }
    else {
        currentSpeedIndex++;
        
        if (self.player.rate != 0) {
            self.player.rate = playbackSpeeds[currentSpeedIndex];
        }
        
        [self.speedButton setTitle:self.playbackSpeedStrings[currentSpeedIndex] forState:UIControlStateNormal];
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
    
    /// Pop back to previous controller in nav stack since the current video no longer exists.
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapScreen:(id)sender
{
    /// A screen tap will [un]hide the UI. Currently this is only allowed if the video is not playing. To allow this
    /// functionality at any time, just get rid of the outer most if clause.
    
    if (self.player.rate != 0) {
        if (self.PlayButton.alpha < 1) {
            [self unhideUI];
        }
        else {
            [self hideUI];
        }
    }
}

#pragma mark Alter UI

-(void) hideUI
{
    /// Top code animates, bottom is instant hide/show
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.navigationController.navigationBar.alpha = 0.0;
    }];
    
    for (UIView *subview in self.view.subviews) {
        [UIView animateWithDuration:0.3 animations:^() {
            subview.alpha = 0.0;
        }];
    }
    
    //    self.navigationController.navigationBarHidden = YES;
    //
    //        for (UIView *subview in self.view.subviews) {
    //            subview.hidden = YES;
    //        }
}

-(void) unhideUI
{
    /// Top code animates, bottom is instant hide/show
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.navigationController.navigationBar.alpha = 1;
    }];
    
    for (UIView *subview in self.view.subviews) {
        if (subview == self.toolbar) {
            [UIView animateWithDuration:0.3 animations:^() {
                subview.alpha = 0.6;
            }];
            
        } else {
            [UIView animateWithDuration:0.3 animations:^() {
                subview.alpha = 1;
            }];
        }
    }
    
    //    self.navigationController.navigationBarHidden = NO;
    //
    //    for (UIView *subview in self.view.subviews) {
    //        subview.hidden = NO;
    //    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /// In response to play rate change, change the play/pause button selected property (which changes the button image).
    /// Also [un]hide the UI depending on play/pause status.
    
    if ([keyPath isEqualToString:@"self.player.rate"]) {
        
        self.PlayButton.selected = (self.player.rate != 0) ? YES : NO;
        if (self.player.rate != 0) {
            [self hideUI];
        } else {
            [self unhideUI];
        }
    }
}




@end

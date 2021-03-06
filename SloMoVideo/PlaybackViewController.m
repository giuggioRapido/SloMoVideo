//
//  PlaybackViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "PlaybackViewController.h"
#import "PlayerView.h"

@interface PlaybackViewController()
{
    id<NSObject> _timeObserverToken;
}

@property (nonatomic, strong) AVPlayer *player;
@property AVPlayerItem *playerItem;
@property AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSArray <NSString*> *playbackSpeedStrings;
@property (nonatomic) BOOL UIHidden;
@property CMTime currentTime;

/// UI
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *speedButton;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;


@end

@implementation PlaybackViewController

int currentSpeedIndex;
float playbackSpeeds[3];
static int PlaybackViewControllerKVOContext = 0;
bool wasPlaying;

#pragma mark View Cycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    /// These arrays are coordinated with the currentSpeedIndex to synchronize the playback speed button's title
    /// with the actual desired speed integer.
    
    self.playbackSpeedStrings = [NSArray arrayWithObjects:@"1x", @"2x", @"0.5x", nil];
    
    playbackSpeeds[0] = 1.0;
    playbackSpeeds[1] = 2.0;
    playbackSpeeds[2] = 0.5;
    
    /// Disable swipe back gesture because it tends to interfere with timeSlider control.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.toolbarHidden = YES;
    
    /// Reset playback speed to 1x whenever view appears and set button title appropriately.
    currentSpeedIndex = 0;
    [self.speedButton setTitle:self.playbackSpeedStrings[currentSpeedIndex] forState:UIControlStateNormal];
    
    /// Create/ configure the AVPlayer
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoToPlay.asset];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    self.playerView.playerLayer.player = self.player;
    self.playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    /// Add observation of player.rate so that the controller can respond to changes in playback
    [self addObserver:self forKeyPath:@"self.player.rate" options:NSKeyValueObservingOptionNew context:&PlaybackViewControllerKVOContext];
    
    /// Set the time slider's max to video duration to track playback progress.
    /// This avoids having to map the duration to a 0 - 1 scale.
    self.timeSlider.maximumValue = CMTimeGetSeconds(self.playerItem.duration);
    
    /// Use a weak self variable to avoid a retain cycle in the block.
    PlaybackViewController __weak *weakSelf = self;
    
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:
                          ^(CMTime time) {
                              weakSelf.timeSlider.value = CMTimeGetSeconds(time);
                          }];
    
    
    /// Programmatic layer:
    //    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //    self.playerLayer.frame = self.view.frame;
    //    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    //    [self.view.layer addSublayer:self.playerLayer];
    
    /// Useful detritus?
    //     NSLog(@"%i", self.playerItem.canPlaySlowForward);
    //     [self.player seekToTime:kCMTimeZero];
    //
    //     NSLog (@"%@", NSStringFromCGRect(self.playerLayer.videoRect));
    
    //    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:
    //                          ^(CMTime time) {
    //                              float currentTimeInSeconds = CMTimeGetSeconds(weakSelf.player.currentTime);
    //                              float durationInSeconds = CMTimeGetSeconds(weakSelf.playerItem.duration);
    //                              float progress = currentTimeInSeconds / durationInSeconds;
    //                              weakSelf.timeSlider.value = progress;
    //                          }];
    
}


- (void)viewDidDisappear:(BOOL)animated
{
    /// When view disappears, pause plaback and remove observers
    
    [self.player pause];
    
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self removeObserver:self forKeyPath:@"self.player.rate" context:&PlaybackViewControllerKVOContext];
    
    [super viewDidDisappear:animated];
}

#pragma mark Properties

- (CMTime)currentTime
{
    return self.player.currentTime;
}

- (void)setCurrentTime:(CMTime)newCurrentTime
{
    [self.player seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark IBAction

- (IBAction)pressPlay:(id)sender
{
    /// If video is playing (player.rate != 0), pause the video.
    /// Else if it's paused, play video at currently selected playback speed.
    /// If the video is at end and user pressed play, start video from beginning.
    
    if (self.player.rate != 0) {
        [self.player pause];
    }
    else {
        if (CMTIME_COMPARE_INLINE(self.player.currentTime, ==, self.playerItem.duration)) {
            [self.player seekToTime:kCMTimeZero];
        }
        
        /// No need to call [self.player play] since setting the speed to anything other than 0 will play video.
        self.player.rate = playbackSpeeds[currentSpeedIndex];
        
        /// And if we are pressing play (rather than pause), hide the UI after a delay, unless the user has already
        /// tapped to hide the UI before the 2 seconds are over.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!self.UIHidden){
                [self hideUI];
            }
        });
        
    }
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
    [[MediaLibrary sharedLibrary] deleteVideo:self.videoToPlay];
    
    /// Pop back to previous controller in nav stack since the current video no longer exists.
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapScreen:(id)sender
{
    /// A screen tap will [un]hide the UI.
    /// The outermost if-clause (commented-out by default) dictates whether the UI can be hidden when video is paused.
    
    //    if (self.player.rate != 0) {
    if (self.UIHidden) {
        [self unhideUI];
    }
    else {
        [self hideUI];
    }
    //    }
}

- (IBAction)touchDownTimeSlider:(id)sender
{
    if (self.player.rate != 0) {
        wasPlaying = YES;
        [self.player pause];
    }
    else {
        wasPlaying = NO;
    }
}
- (IBAction)touchUpTimeSlider:(id)sender
{
    if (wasPlaying) {
    self.player.rate = playbackSpeeds[currentSpeedIndex];
    }
}

- (IBAction)adjustTimeSlider:(UISlider*)sender
{
    self.currentTime = CMTimeMakeWithSeconds(sender.value, 1000);
}

#pragma mark Alter UI

-(void) hideUI
{
    /// UIisHidden is used in conjuction with setNeedsStatusBarAppearanceUpdate to hide/show the status bar
    
    self.UIHidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^() {
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.alpha = 0.0;
    }];
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.toolbar.alpha = 0;
        self.timeSlider.alpha = 0;
    }];
}

-(void) unhideUI
{
    /// UIisHidden is used in conjuction with setNeedsStatusBarAppearanceUpdate to hide/show the status bar
    
    self.UIHidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^() {
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.alpha = 1;
    }];
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.toolbar.alpha = 1.0;
        self.timeSlider.alpha = 1.0;
    }];
    
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /// In response to play rate change, change the play/pause button selected property (which changes the button image).
    /// Also [un]hide the UI depending on play/pause status.
    
    if ([keyPath isEqualToString:@"self.player.rate"]) {
        
        /// Toggle play/pause button image in response to player.rate
        self.PlayButton.selected = (self.player.rate != 0) ? YES : NO;
        
        /// When the video stops playing at the end, unhide UI
        if (self.player.rate == 0) {
            [self unhideUI];
        }
    }
}

-(BOOL)prefersStatusBarHidden
{
    /// Nav bar alpha adjustments necessary here so that navbar doesn't erroniously reappear when orientation changes
    if (self.UIHidden) {
        self.navigationController.navigationBar.alpha = 0;
        return YES;
    }
    else {
        self.navigationController.navigationBar.alpha = 1;
        return NO;
    }
}

#pragma mark TO DO

/// Add share features (Save to photos, email, message, etc.)

@end

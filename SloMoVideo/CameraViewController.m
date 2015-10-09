//
//  CameraViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/23/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Camera";
    
    /// Create the AVCaptureSession.
    self.session = [[AVCaptureSession alloc] init];
   	
    /// Setup the preview view.
    self.previewView.session = self.session;
    
    /// Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    /// Check video authorization status. Video access is required and audio access is optional.
    /// If audio access is denied, audio is not recorded during movie recording.
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            /// The user has previously granted access to the camera.
            break;
        }
            
        case AVAuthorizationStatusNotDetermined:
        {
            /// The user has not yet been presented with the option to grant video access.
            /// We suspend the session queue to delay session setup until the access request has completed to avoid
            /// asking the user for audio access if video access is denied.
            /// Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( ! granted ) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
            
        default:
        {
            /// The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    /// Setup the capture session.
    /// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    /// Why not do all of this on the main queue?
    /// Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    /// so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult != AVCamSetupResultSuccess ) {
            return;
        }
        
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        /// Following line uses a method to select specified device
        //        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        /// Save the default format
        self.defaultFormat = videoDevice.activeFormat;
        self.defaultVideoMaxFrameDuration = videoDevice.activeVideoMaxFrameDuration;
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (!videoDeviceInput) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        [self.session beginConfiguration];
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            
            dispatch_async( dispatch_get_main_queue(), ^{
                /// Why are we dispatching this to the main queue?
                /// Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                /// can only be manipulated on the main thread.
                
                /// Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                /// -[viewWillTransitionToSize:withTransitionCoordinator:].
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
                previewLayer.connection.videoOrientation = initialVideoOrientation;
            });
        }
        else {
            NSLog( @"Could not add video device input to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if ( ! audioDeviceInput ) {
            NSLog( @"Could not create audio device input: %@", error );
        }
        
        if ( [self.session canAddInput:audioDeviceInput] ) {
            [self.session addInput:audioDeviceInput];
        }
        else {
            NSLog( @"Could not add audio device input to the session" );
        }
        
        /// Create AVCaptureMovieFileOutput object
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ( [self.session canAddOutput:movieFileOutput] ) {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( connection.isVideoStabilizationSupported ) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
        }
        else {
            NSLog( @"Could not add movie file output to the session" );
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        [self.session commitConfiguration];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    dispatch_async( self.sessionQueue, ^{
        switch ( self.setupResult )
        {
            case AVCamSetupResultSuccess:
            {
                /// Only start the session running if setup succeeded.
                [self.session startRunning];
                self.sessionRunning = self.session.isRunning;
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"SloMoVideo doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SloMoVideo" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    /// Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration" );
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
        }
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async( self.sessionQueue, ^{
        if ( self.setupResult == AVCamSetupResultSuccess ) {
            [self.session stopRunning];
        }
    } );
    
    [super viewDidDisappear:animated];
}

#pragma mark Actions

- (IBAction)startRecording:(id)sender
{
    dispatch_async( self.sessionQueue, ^{
        if ( [UIDevice currentDevice].isMultitaskingSupported ) {
            /// Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
            /// callback is not received until app returns to the foreground unless you request background execution time.
            /// This also ensures that there will be time to write the file to the photo library when app is backgrounded.
            /// To conclude this background execution, -endBackgroundTask is called in
            /// -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
            self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        
        /// Update the orientation on the movie file output video connection before starting recording.
        AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        connection.videoOrientation = previewLayer.connection.videoOrientation;
        
        /// Create file name from date
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        NSString* fileName = [NSString stringWithFormat:@"%@.mov",[formatter stringFromDate:[NSDate date]]];
        
        /// Start recording to Documents directory.
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        
        [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
    } );
}

- (IBAction)stopRecording:(id)sender
{
    /// This method is called when the user double taps anywhere on the screen.
    /// Only stop recording if we're currently recording.
    
    if (self.movieFileOutput.isRecording) {
        [self.movieFileOutput stopRecording];
    }
}

- (IBAction)toggleSloMo:(id)sender
{
    /// When button is selected, it is in the high FPS state. Background color needs to be set separately, however, since
    /// 'selected' doesn't allow for different BG color
    
    if (self.sloMoToggle.selected) {
        /// Code here is for default FPS
        self.sloMoToggle.selected = NO;
        self.sloMoToggle.backgroundColor = [UIColor darkGrayColor];
        
        [self returnFPSToDefault];
        
    }
    else {
        /// Code here is for activating high FPS
        self.sloMoToggle.selected = YES;
        self.sloMoToggle.backgroundColor = self.view.tintColor;
        
        [self increaseFPS];
    }
}

- (IBAction)showVideoLibrary:(id)sender
{
    [self performSegueWithIdentifier:@"segueToLibrary" sender:sender];
    //[self.navigationController pushViewController:self.navigationController.viewControllers[1] animated:YES];
}

-(void) displayRecordingUI
{
    /// Things that should disappear:
    UIColor *borderColor = [UIColor colorWithRed:206.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0];
    self.previewView.layer.borderColor = borderColor.CGColor;
    self.previewView.layer.borderWidth = 3.0f;
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.recordButton.alpha = 0.0;
        self.sloMoToggle.alpha = 0.0;
        self.libraryButton.alpha = 0.0;
    }];
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.toolbar.alpha = 0.0;
    }];
    
    /// Things that should appear:
    [UIView animateWithDuration:0.3 animations:^() {
        self.doubleTapLabel.alpha = 1.0;
    }];
    
    /// And then re-hide the double tap tip after a delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^() {
            self.doubleTapLabel.alpha = 0.0;
        }];
    });
}

-(void) displayViewFinderUI
{
    /// Things that should appear:
    [UIView animateWithDuration:0.3 animations:^() {
        self.recordButton.alpha = 1.0;
        self.sloMoToggle.alpha = 1.0;
        self.libraryButton.alpha = 1.0;
    }];
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.toolbar.alpha = 0.6;
    }];
    
    /// Things that should disappear:
    self.previewView.layer.borderColor = nil;
    self.previewView.layer.borderWidth = 0;
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.doubleTapLabel.alpha = 0.0;
    }];
}

#pragma mark Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    /// Note that the app delegate controls the device orientation notifications required to use the device orientation.
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
        previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

#pragma mark Device Configuration

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    /// devicesWithMediaType returns array of devices that support the passed in mediaType.
    /// In the case of video, front and back cameras are the devices.
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    /// Check the passed in position against the devices and return desired device.
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

-(void) increaseFPS
{
    if (self.session.isRunning){
        [self.session stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    AVFrameRateRange *frameRateRange = nil;
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            if (range.minFrameRate <= 60.0 && 60.0 <= range.maxFrameRate) {
                selectedFormat = format;
                frameRateRange = range;
            }
        }
    }
    
    if (selectedFormat) {
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)60.0);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)60.0);
            [videoDevice unlockForConfiguration];
        }
    }
    if (!self.session.isRunning) [self.session startRunning];
}

-(void) returnFPSToDefault
{
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [videoDevice lockForConfiguration:nil];
    videoDevice.activeFormat = self.defaultFormat;
    videoDevice.activeVideoMaxFrameDuration = self.defaultVideoMaxFrameDuration;
    [videoDevice unlockForConfiguration];
    
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

#pragma mark File Output Recording Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    /// Hide the record button and color border to indicate that camera is recording
    dispatch_async( dispatch_get_main_queue(), ^{
        [self displayRecordingUI];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    /// Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    /// This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    /// is back to NO — which happens sometime after this method returns.
    /// Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    BOOL success = YES;
    
    if ( error ) {
        NSLog( @"Movie file finishing error: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if ( success ) {
        NSLog(@"file saved");
    }
    
    /// Unhide the record button and get rid of recording border
    dispatch_async( dispatch_get_main_queue(), ^{
        [self displayViewFinderUI];
    });
}

@end

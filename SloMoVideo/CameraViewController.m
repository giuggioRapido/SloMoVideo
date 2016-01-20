//
//  CameraViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/23/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "CameraViewController.h"

typedef NS_ENUM(NSInteger, AVCamSetupResult)
{
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};


@interface CameraViewController()

/// UI
@property (weak, nonatomic) IBOutlet PreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *sloMoToggle;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *doubleTapLabel;
@property (strong, nonatomic) UIView *borderBuddy;
@property (strong, nonatomic) UIColor *defaultToolbarColor;


/// Session management
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) dispatch_queue_t sessionQueue;
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureDeviceFormat *defaultFormat;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;

@property (strong, nonatomic) NSMutableDictionary <NSString*, AVCaptureDeviceFormat*> *fpsOptions;
@property (strong, nonatomic) NSArray <NSString*> *sortedFormatKeys;


@property (strong, nonatomic) NSString *currentFPS;

/// Utilities
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@end

@implementation CameraViewController

#pragma mark View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Camera";
    
    
    self.defaultToolbarColor = self.toolbar.backgroundColor;
    
    /// Create the AVCaptureSession. Set preset to highest resolution. Initial camera setting on 5s, e.g. will be
    /// Initial camera setting on 5s, e.g. will be 30 FPS at 1080p
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
   	
    /// Setup the preview view.
    self.previewView.session = self.session;
    
    /// Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    self.setupResult = AVCamSetupResultSuccess;
    
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
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^( BOOL granted ) {
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
    /// Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async (self.sessionQueue, ^{
        if (self.setupResult != AVCamSetupResultSuccess) {
            return;
        }
        
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        NSError *error = nil;
        
        /// We're using the default device, but the commented line shows how to do a specific device.
        /// The default device here ends up being the back facing camera.
        self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //        AVCaptureDevice *videoDevice = [CameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
        if (!self.videoDevice) {
            NSLog(@"There was a problem creating the video device");
        }
        
        
        /// Create dictionary to store the desired formats
        self.fpsOptions = [[NSMutableDictionary alloc] init];
        
        /// Look through available formats for current device
        /// Set up variables to store pertinent information about each format.
        /// Look through framerates in each format.
        /// Multiple formats will have the same framerate ranges, so we evaluate
        /// in groups of similar formats and by checking each format against the
        /// previous format, we finally select for the "best" format for each
        /// desired framerate.
        /// In our case, "best" means that each selected format has the highest
        /// resolution for that framerate and has full range.
        /// The chosen formats are saved in a dictionary for use elsewhere.
        for (AVCaptureDeviceFormat *format in self.videoDevice.formats) {
            CMFormatDescriptionRef formatDescription = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
            FourCharCode mediaSubType = CMFormatDescriptionGetMediaSubType(formatDescription);
            BOOL fullRange = NO;
            
            /// We want only the formats with full range, so we use a bool to select for those.
            switch (mediaSubType) {
                case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                    fullRange = NO;
                    break;
                case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
                    fullRange = YES;
                    break;
                default:
                    NSLog(@"Unknown media subtype encountered in format: %@", format);
                    break;
            }
            
            for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
                NSUInteger maxFrameRate = (NSUInteger)range.maxFrameRate;
                NSString *maxFrameRateAsString = [NSString stringWithFormat:@"%lu", (unsigned long)maxFrameRate];
                
                if (![self.fpsOptions objectForKey:maxFrameRateAsString]) {
                    [self.fpsOptions setObject:format forKey: maxFrameRateAsString];
                    
                } else {
                    AVCaptureDeviceFormat *bestFormatForCurrentFrameRate = [self.fpsOptions objectForKey:maxFrameRateAsString];
                    CMFormatDescriptionRef bestFDR = bestFormatForCurrentFrameRate.formatDescription;
                    CMVideoDimensions bestDimensions = CMVideoFormatDescriptionGetDimensions(bestFDR);
                    
                    if (dimensions.height > bestDimensions.height && dimensions.height <= 1080 && fullRange == YES) {
                        bestFormatForCurrentFrameRate = format;
                        [self.fpsOptions setObject:bestFormatForCurrentFrameRate forKey:maxFrameRateAsString];
                        /// The following lines are necessary because in 240 fps capable devices, there isn't a dedicated 120 fps format. Per Apple's documentation, to record at 120, use a 240 fps format and manually set the frame duration (this is done in the changeFPS method).
                        if (maxFrameRate == 240) {
                            [self.fpsOptions setObject:bestFormatForCurrentFrameRate forKey:@"120"];
                        }
                    }
                }
            }
        }
        
        /// We make an array that orders the saved video formats in order, making it easier to iterate through them in pertinent locations,
        /// i.e. in the toggleSloMo method, where we want the button to cycle through the formats in ascending order.
        NSMutableArray *presortedFormats = [[NSMutableArray alloc] init];
        self.sortedFormatKeys = [[NSArray alloc] init];
        
        /// First, add just the dict's keys to an array for sorting.
        for (NSString* key in self.fpsOptions) {
            [presortedFormats addObject: key];
        }
        
        /// Now sort those keys from lowest-highest (i.e. 30, 60, 120, 240...)
        self.sortedFormatKeys = [presortedFormats sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue]==[obj2 intValue])
                return (NSComparisonResult)NSOrderedSame;
            
            else if ([obj1 intValue]<[obj2 intValue])
                return (NSComparisonResult)NSOrderedAscending;
            else
                return (NSComparisonResult)NSOrderedDescending;
            
        }];
        
        /// Set the currentFPS and default active format to the lowest fps format.
        if ([self.fpsOptions objectForKey:self.sortedFormatKeys.firstObject]) {
            self.currentFPS = self.sortedFormatKeys.firstObject;
            if ([self.videoDevice lockForConfiguration:NULL] == YES) {
                [self changeFPS];
                [self.videoDevice unlockForConfiguration];
            }
            /// Change appearance of button to reflect format adjustment.
            NSString *buttonTitle = [NSString stringWithFormat:@"%@ FPS", self.currentFPS];
            [self.sloMoToggle setTitle:buttonTitle forState: UIControlStateNormal];
        }
        else {
            NSLog(@"There was a problem creating the fpsOptions dictionary");
        }
        
        
        /// Create input object
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
        
        if (!videoDeviceInput) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        /// Configure session
        [self.session beginConfiguration];
        
        if ([self.session canAddInput:videoDeviceInput]) {
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
            NSLog(@"Could not add video device input to the session");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (!audioDeviceInput) {
            NSLog(@"Could not create audio device input: %@", error);
        }
        
        if ([self.session canAddInput:audioDeviceInput]) {
            [self.session addInput:audioDeviceInput];
        }
        else {
            NSLog(@"Could not add audio device input to the session");
        }
        
        /// Create AVCaptureMovieFileOutput object
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ([self.session canAddOutput:movieFileOutput]) {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if (connection.isVideoStabilizationSupported) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
        }
        else {
            NSLog(@"Could not add movie file output to the session");
            self.setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        [self.session commitConfiguration];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    dispatch_async( self.sessionQueue, ^{
        switch (self.setupResult)
        {
            case AVCamSetupResultSuccess:
            {
                /// Only start the session running if setup succeeded.
                /// -starRunning is placed in lock block because this is needed if we want the coder-assigned
                /// format to be used rather than the format dictated by the session preset.
                /// With that said, it hasn't been working as expected. But in a practical sense,
                /// this doesn't matter since the default session preset is the format we'd want anyway.
                if ([self.videoDevice lockForConfiguration:NULL] == YES) {
                    [self.session startRunning];
                    self.sessionRunning = self.session.isRunning;
                    [self.videoDevice unlockForConfiguration];
                }
                break;
            }
            case AVCamSetupResultCameraNotAuthorized:
            {
                dispatch_async (dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString(@"SloMoVideo doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera");
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SloMoVideo" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    /// Provide quick access to Settings.
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Alert button to open Settings") style:UIAlertActionStyleDefault handler:^( UIAlertAction *action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                } );
                break;
            }
            case AVCamSetupResultSessionConfigurationFailed:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *message = NSLocalizedString( @"Unable to capture media", @"Alert message when something goes wrong during capture session configuration");
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
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
        if (self.setupResult == AVCamSetupResultSuccess) {
            [self.session stopRunning];
        }
    } );
    
    [super viewDidDisappear:animated];
}


#pragma mark Actions

- (IBAction)startRecording:(id)sender
{
    dispatch_async (self.sessionQueue, ^{
        if ([UIDevice currentDevice].isMultitaskingSupported) {
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
        NSString* fileName = [NSString stringWithFormat:@"%@-%@.mov",[formatter stringFromDate:[NSDate date]], self.currentFPS];
        
        /// Start recording to Documents directory.
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        
        [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
    });
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
    /// Create button colors for each of the FPS settings and add them to a dictionary that uses the fps options as keys.
    UIColor *blue = [UIColor colorWithRed:0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor *blueGreen = [UIColor colorWithRed:0 green:149.0/255.0 blue:139.0/255.0 alpha:1.0];
    UIColor *green = [UIColor colorWithRed:0 green:179.0/255.0 blue:95.0/255.0 alpha:1.0];
    UIColor *orange = [UIColor colorWithRed:255/255.0 green:153.0/255.0 blue:0 alpha:1.0];
    
    NSDictionary *buttonColors = @{@"30":blue, @"60":blueGreen, @"120":green, @"240":orange};
    
    /// Increment the button's tag, which is then used to iterate through the available framerates.
    self.sloMoToggle.tag++;
    if (self.sloMoToggle.tag == self.fpsOptions.count) {
        self.sloMoToggle.tag = 0;
    }
    
    /// Get the NSString representing the desired framerate from self.sortedFormatKeys array.
    self.currentFPS = self.sortedFormatKeys[self.sloMoToggle.tag];
    
    /// Change appearance of button to reflect format adjustment.
    NSString *buttonTitle = [NSString stringWithFormat:@"%@ FPS", self.currentFPS];
    [self.sloMoToggle setTitle:buttonTitle forState: UIControlStateNormal];
    //self.sloMoToggle.backgroundColor = [buttonColors objectForKey:self.currentFPS];
    
    /// Actually change the format.
    [self changeFPS];
}

- (IBAction)showVideoLibrary:(id)sender
{
    [self performSegueWithIdentifier:@"segueToLibrary" sender:sender];
}

- (void)displayRecordingUI
{
    /// Things that should disappear:
    [UIView animateWithDuration:0.3 animations:^() {
        self.toolbar.alpha = 0.0;
    }];
    
    /// Things that should appear:
    UIColor *borderColor = [UIColor colorWithRed:206.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0];
    self.previewView.layer.borderColor = borderColor.CGColor;
    self.previewView.layer.borderWidth = 4.0f;
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.doubleTapLabel.alpha = 1.0;
    }];
    
    /// borderBuddy is needed so that the border doesn't disappear when doubleTapLabel disappears below.
    if (!self.borderBuddy) {
        self.borderBuddy = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        self.borderBuddy.backgroundColor = [UIColor whiteColor];
        [self.previewView addSubview:self.borderBuddy];
    }
    else {
        self.borderBuddy.hidden = NO;
    }
    
    /// And then re-hide the double tap tip after a delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^() {
            self.doubleTapLabel.alpha = 0.0;
        }];
    });
    
    
    /// Useful detritus?
    //    NSLog(@"Border did appear\n\nself.previewView:%@\n\nlayer: %@\n\nborder color: %@", self.previewView, self.previewView.layer, self.previewView.layer.borderColor);
}

- (void)displayViewFinderUI
{
    /// Things that should appear:
    [UIView animateWithDuration:0.3 animations:^() {
        self.toolbar.alpha = 1.0;
    }];
    
    /// Things that should disappear:
    self.previewView.layer.borderColor = nil;
    self.previewView.layer.borderWidth = 0;
    
    self.borderBuddy.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^() {
        self.doubleTapLabel.alpha = 0.0;
    }];
}

#pragma mark Orientation
- (BOOL)shouldAutorotate
{
    /// Disable autorotation of the interface when recording is in progress.
    return ! self.movieFileOutput.isRecording;
}

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
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

- (void)changeFPS
{
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
    
    AVCaptureDeviceFormat *selectedFormat = [self.fpsOptions objectForKey:self.currentFPS];
    
    if (selectedFormat) {
        if ([self.videoDevice lockForConfiguration:nil]) {
            self.videoDevice.activeFormat = selectedFormat;
            /// The next two lines are really only necessary in the event that the device has a 240 fps format. See the initial format selection in viewDidLoad for an explanation.
            self.videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, self.currentFPS.intValue);
            self.videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, self.currentFPS.intValue);
            [self.videoDevice unlockForConfiguration];
            NSLog(@"changed to format: %@", self.videoDevice.activeFormat);
            NSLog(@"min frame duration: %f, max frameduration: %f", CMTimeGetSeconds(self.videoDevice.activeVideoMinFrameDuration), CMTimeGetSeconds(self.videoDevice.activeVideoMaxFrameDuration));
            
        }
    }
    
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
    
}


#pragma mark File Output Recording Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    /// Hide the record button and color border to indicate that camera is recording
    dispatch_async (dispatch_get_main_queue(), ^{
        [self displayRecordingUI];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    /// Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    /// This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    /// is back to NO — which happens sometime after this method returns.
    /// Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    //    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    //    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    BOOL success = YES;
    
    if ( error ) {
        NSLog( @"Movie file finishing error: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if ( success ) {
        NSLog(@"file saved");
        [[MediaLibrary sharedLibrary] pullMostRecentFile];
    }
    
    /// Revert to view finder UI
    dispatch_async (dispatch_get_main_queue(), ^{
        [self displayViewFinderUI];
    });
}


#pragma mark - UITextFieldDelegate

/// In this method, we keep track of the content of the texfield at any given moment so that we can enable/disable buttons (i.e. only enable Confirm if the textfield count is >0)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    UIResponder *responder = textField;
    Class uiacClass = [UIAlertController class];
    while (![responder isKindOfClass: uiacClass])
    {
        responder = [responder nextResponder];
    }
    UIAlertController *alert = (UIAlertController*) responder;
    UIAlertAction *setPassword  = [alert.actions objectAtIndex: 1];
    
    if (newString.length == 0) {
        setPassword.enabled = NO;
        return YES;
    }
    else {
        setPassword.enabled = YES;
        return YES;
    }
}




#pragma mark Other

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/// Adding this in hopes it fixes memory warnings
- (void)dealloc {
    AVCaptureInput* input = [self.session.inputs objectAtIndex:0];
    [self.session removeInput:input];
    AVCaptureVideoDataOutput* output = [self.session.outputs objectAtIndex:0];
    [self.session removeOutput:output];
    [self.session stopRunning];
}

#pragma mark TO DO

/// Fix the buggy-looking state switching for the slo mo toggle
/// Make some views scale to be larger on iPad, not simply scale to fit screen (e.g. camera controls)
/// Add focus, exposure, flash control.
/// INTERCEPT ERRORS THROUGHOUT APP ///


@end

//
//  VideoLibraryViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "VideoLibraryViewController.h"

@interface VideoLibraryViewController()

@property (nonatomic, strong) NSMutableArray <Video*> *videos;
@property (nonatomic, strong) NSMutableArray <Video*> *videosToDelete;
@property (nonatomic, strong) Video *videoToPlay;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteVideosButton;

@end

@implementation VideoLibraryViewController

#pragma mark View Cycle

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Library";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.videos = [[MediaLibrary sharedLibrary] videos];
    self.videosToDelete = [[NSMutableArray alloc] init];
    
    /// Changing a bar buttom item's text color requires this method, apparently.
    [self.deleteVideosButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    /// If video was deleted in the Playback VC, reload collection view to reflect the deletion.
    if ([[MediaLibrary sharedLibrary] videoWasDeleted] == YES) {
        [[MediaLibrary sharedLibrary] setVideoWasDeleted: NO];
        [self.collectionView reloadData];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    /// If we've clicked Done (i.e. stop editing), clear deletion array and deselect all selected cells.
    /// Call didSelect manually so that we call -deselect on each cell
    if (!editing) {
        [self.videosToDelete removeAllObjects];
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
        }
    }
    
    /// Only allow multiple selection when we are editing
    self.collectionView.allowsMultipleSelection = self.editing;
    
    /// Show/hide toolbar with Delete Videos button
    [self.navigationController setToolbarHidden: !self.editing animated:YES];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *cell = (Cell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    Video *currentVideo = [self.videos objectAtIndex:indexPath.row];
    
    cell.durationLabel.text = currentVideo.duration;
    cell.fpsLabel.text = currentVideo.fps;
    cell.imageView.image = currentVideo.thumbnail;
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /// If we're editing, only select the cells for deletion. Else play the selected video.
    
    if (self.editing) {
        Cell *selectedCell = (Cell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        if ([self.videos objectAtIndex:indexPath.row]){
            Video *selectedVideo = [self.videos objectAtIndex:indexPath.row];
            [selectedCell select];
            [self.videosToDelete addObject:selectedVideo];
        }
        else {
            NSLog(@"A video doesn't exist at selected indexpath.row");
        }
    }
    else {
        /// Store the video at selected indexpath for use in segue.
        self.videoToPlay = [self.videos objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"segueToPlayer" sender:self];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *selectedCell = (Cell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    Video *selectedVideo = [self.videos objectAtIndex:indexPath.row];
    
    [selectedCell deselect];
    [self.videosToDelete removeObject:selectedVideo];
}


#pragma mark Actions

- (IBAction)deleteVideos:(id)sender
{
    /// Loop through selected indexpaths and deselect them. We can't simply call the didDeselect callback method
    /// because it will remove objects from the videosToDelete array, so we just call deselect on the cells directly.
    /// We need -deselectItemAtIndexPath because otherwise the cells will delete, but the cells that take their places
    /// will "inherit" selected state (i.e. selection is based on index paths, not the cells themselves).
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        Cell *selectedCell = (Cell*)[self.collectionView cellForItemAtIndexPath:indexPath];
        [selectedCell deselect];
    }
    
    /// Delete selected videos from model and clear the videosToDelete array
    [[MediaLibrary sharedLibrary] deleteBatchOfVideos: self.videosToDelete];
    [self.videosToDelete removeAllObjects];
    
    /// Reload collection view to show changes
    [self.collectionView reloadData];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender
{
    /// Pass selected video to Playback VC.
    PlaybackViewController *vc = segue.destinationViewController;
    vc.videoToPlay = self.videoToPlay;
}

#pragma mark – PasscodeAlertHanding
- (void)presentEnterPasscodeAlert
{
    __block UIAlertController *alert = [UIAlertController enterPasscodeAlertWithEnterBehavior:^{
        
        if (![PasscodeServices isPasscodeValid:alert.textFields[0].text]) {
            [self presentEnterPasscodeAlert];
        }
    }];
    
    alert.textFields[0].delegate = self;
    
    [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark To Do

@end

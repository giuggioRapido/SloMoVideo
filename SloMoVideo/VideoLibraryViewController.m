//
//  VideoLibraryViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "VideoLibraryViewController.h"

@interface VideoLibraryViewController()

@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) NSMutableArray *videosToDelete;
@property (nonatomic, strong) Video *videoToPlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteVideosButton;

@end

@implementation VideoLibraryViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Library";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.videos = [[MediaLibrary sharedLibrary] videos];
    self.videosToDelete = [[NSMutableArray alloc] init];
    
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
    cell.imageView.image = currentVideo.thumbnail;
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        NSLog(@"selected items: %lu", self.collectionView.indexPathsForSelectedItems.count);
        Cell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        Video *selectedVideo = [self.videos objectAtIndex:indexPath.row];
        
        [selectedCell select];
        [self.videosToDelete addObject:selectedVideo];
    }
    else {
        /// Store the video at selected indexpath for use in segue.
        self.videoToPlay = [self.videos objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"segueToPlayer" sender:self];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Cell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    Video *selectedVideo = [self.videos objectAtIndex:indexPath.row];
    
    [selectedCell deselect];
    [self.videosToDelete removeObject:selectedVideo];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    //    self.navigationController.toolbarHidden = editing;
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    }
    
    self.collectionView.allowsMultipleSelection = self.editing;
    [self.navigationController setToolbarHidden:!self.editing animated:YES];

    //    self.collectionView.allowsSelection = NO;
    //    self.collectionView.allowsSelection = YES;
    
   
    
    NSLog(@"selected items: %lu", self.collectionView.indexPathsForSelectedItems.count);
}

#pragma mark Actions

- (IBAction)deleteVideos:(id)sender
{
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        Video *selectedVideo = [self.videos objectAtIndex:indexPath.row];
        [[MediaLibrary sharedLibrary] deleteVideo: selectedVideo];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
    }
   
    [self.collectionView reloadData];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender
{
    /// Pass selected video to Playback VC.
    PlaybackViewController *vc = segue.destinationViewController;
    vc.videoToPlay = self.videoToPlay;
}

#pragma mark
/*
 Allow for deletion of videos.
 The VC will exist in two states: either editing or not.
 If not editing, multiple selection is turned off and selecting a cell simply pushes to playback.
 If editing is on, multiple selection is on,
 touching cells with call select on them
 Touching them while they're seleted will call deselect on them
 Ending editing state will deselect all cells
 if editing, show toolbar with delete button
 when delete button is pressed, delete all selected cells
 
 */

@end

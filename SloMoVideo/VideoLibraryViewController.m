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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    /// If we've clicked Done (i.e. stop editing), clear deletion array and deselect all selected cells.
    /// Call didSelect manuallyso that we call -deselect on each cell
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
    [self.navigationController setToolbarHidden:!self.editing animated:YES];
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
    /// If we're editing, only select the cells for deletion. Else play the selected video.
    
    if (self.editing) {
        NSLog(@"nr of selected items: %lu", self.collectionView.indexPathsForSelectedItems.count);
       // NSLog(@"selected indexpath: %ld", (long)indexPath.row);
        
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
    
    NSLog(@"nr of selected items: %lu", self.collectionView.indexPathsForSelectedItems.count);
}


#pragma mark Actions

- (IBAction)deleteVideos:(id)sender
{
    NSLog(@"nr of selected items: %lu", self.collectionView.indexPathsForSelectedItems.count);

    /// Loop through selected indexpaths and deselect them. We can't simply call the didDeselect callback method
    /// because it will remove objects from the videosToDelete array, so we just call deselect on the cells directly.
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        Cell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [selectedCell deselect];
    }
    
    NSLog(@"nr of selected items: %lu", self.collectionView.indexPathsForSelectedItems.count);

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

#pragma mark

@end

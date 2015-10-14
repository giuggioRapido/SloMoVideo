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
@property (nonatomic, strong) Video *videoToPlay;

@end

@implementation VideoLibraryViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Library";
    
    self.videos = [[MediaLibrary sharedLibrary] videos];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;
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
    /// Store the video at selected indexpath for use in segue.
    self.videoToPlay = [self.videos objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueToPlayer" sender:self];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender
{
    /// Pass selected video to Playback VC.
    PlaybackViewController *vc = segue.destinationViewController;
    vc.videoToPlay = self.videoToPlay;
}


@end

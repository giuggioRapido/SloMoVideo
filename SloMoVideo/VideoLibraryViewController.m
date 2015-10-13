//
//  VideoLibraryViewController.m
//  SloMoVideo
//
//  Created by Chris on 9/30/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "VideoLibraryViewController.h"

@implementation VideoLibraryViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Library";

    self.videos = [[Model sharedModel] videos];
    self.model = [Model sharedModel];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
//    
//    if (self.videos.count != directoryContent.count) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            //[self pullDocumentsContents];
//            [[Model sharedModel] pullVideosFromDocuments];
//        });
//    }
    
    [[Model sharedModel] addObserver:self forKeyPath:@"self.videosCountForKVO" options:NSKeyValueObservingOptionNew context:nil];

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
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
    self.videoToPlay = [self.videos objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueToPlayer" sender:self];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender
{
    videoPlayerViewController *vc = segue.destinationViewController;
    vc.videoToPlay = self.videoToPlay;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
}

@end

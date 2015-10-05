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
    self.videos = [[NSMutableArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    
    for (int count = 0; count < (int)[directoryContent count]; count++)
    {
        //NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        NSString *videoPath = [documentsPath stringByAppendingPathComponent:[directoryContent objectAtIndex:count]];

        Video *video = [[Video alloc]init];
        video.path = [NSURL fileURLWithPath:videoPath];
        video.asset = [AVURLAsset assetWithURL:video.path];
        
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]
                                                 initWithAsset:video.asset];
        
        Float64 durationSeconds = CMTimeGetSeconds(video.asset.duration);
        CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
        
        NSError *error;
        CMTime actualTime;
        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint
                                                         actualTime:&actualTime error:&error];
        //NSLog(@"err = %@, imageRef = %@", error, halfWayImage);
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:halfWayImage];
        
        video.thumbnail = thumbnailImage;
        
        [self.videos addObject:video];
    }
}


#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.videoToPlay = [self.videos objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segueToPlayer" sender:self];
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

- (void)prepareForSegue:(UIStoryboardSegue * _Nonnull)segue sender:(id _Nullable)sender
{
    videoPlayerViewController *vc = segue.destinationViewController;
    vc.videoToPlay = self.videoToPlay;
}

@end

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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    
    if (self.videos.count != directoryContent.count) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self pullDocumentsContents];
        });
    }
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
   // NSLog(@"%lu", (unsigned long)self.directoryContent.count);
    
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

#pragma mark Custom methods

-(void) pullDocumentsContents
{
    /// Clear videos array, which will be repopulated in loop below. At bottom of method, reloadData is called on the
    /// collection view to update it in case video has been deleted in the player view controller
    
    [self.videos removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    
    /// The following two for statements change the direction in which the iterate through the documents contents.
    /// Ultimately this changes whether thumbnails are listed in newest->oldest or vice versa.
    //    for (int count = 0; count < (int)[directoryContent count]; count++)
    for (int count = (int)directoryContent.count - 1; count >= 0; count--)
    {
        NSString *videoPath = [documentsPath stringByAppendingPathComponent:[directoryContent objectAtIndex:count]];
        
        Video *video = [[Video alloc]init];
        video.path = [NSURL fileURLWithPath:videoPath];
        video.stringPath = videoPath;
        video.asset = [AVURLAsset assetWithURL:video.path];
        
        /// Generate thumbnails
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]
                                                 initWithAsset:video.asset];
        
        Float64 durationSeconds = CMTimeGetSeconds(video.asset.duration);
        
        CMTime startpoint = CMTimeMakeWithSeconds(0.0, 600);
        //        CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
        
        NSError *error;
        CMTime actualTime;
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            }
            UIImage *unresizedImage = [[UIImage alloc] initWithCGImage:image
                                                                 scale:1.0
                                                           orientation:UIImageOrientationRight];
            
            video.thumbnail = [unresizedImage resizedImageWithScaleFactor:0.1];
            
            [self.videos addObject:video];
            
            if (self.videos.count == directoryContent.count) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                } );
            }
            
        };
        
        [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:startpoint]] completionHandler:handler];
        
        
        //        /// Pass in either startpoint or midpoint depending on where you want the thumbnail to come from
        //        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:startpoint
        //                                                         actualTime:&actualTime error:&error];
        //
        //        /// Orientation needs to be changed because (for some reason) if not done, the thumbnails come out rotated 90 deg
        //        UIImage *unresizedImage = [[UIImage alloc] initWithCGImage:halfWayImage
        //                                                             scale:1.0
        //                                                       orientation:UIImageOrientationRight];
        //
        //        /// Resize the image and assign to video thumbnail
        //        video.thumbnail = [unresizedImage resizedImageWithScaleFactor:0.1];
        //
        //        [self.videos addObject:video];
    }
    
}

@end

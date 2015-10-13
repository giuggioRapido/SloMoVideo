//
//  MediaLibrary.m
//  SloMoVideo
//
//  Created by Chris on 10/9/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "MediaLibrary.h"

@implementation MediaLibrary

+(id)sharedLibrary
{
    static MediaLibrary *sharedLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLibrary = [[self alloc] init];
    });
    return sharedLibrary;
}

- (id)init
{
    if (self = [super init]) {
        self.videos = [[NSMutableArray alloc]init];
        return self;
    } else {
        return nil;
    }
}

- (NSUInteger) videosCountForKVO
{
    return self.videos.count;
}

-(void) initialPullFromDocuments
{
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
        video.stringPath = videoPath;
        video.path = [NSURL fileURLWithPath:videoPath];
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
            
            
        };
        
        [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:startpoint]] completionHandler:handler];
        
        [self.videos addObject:video];
        
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

-(void) pullMostRecentFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    
    /// Grab the path of the video at the end of the directory (i.e. the most recently added file)
    NSString *videoPath = [documentsPath stringByAppendingPathComponent:directoryContent[directoryContent.count - 1]];
    
    Video *video = [[Video alloc]init];
    video.stringPath = videoPath;
    video.path = [NSURL fileURLWithPath:videoPath];
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
        
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:startpoint]] completionHandler:handler];
    
    /// Because we want the videos array to be newest->oldest, we insert video at index 0. If we want it the other way,
    /// just simply call addObject.
    [self.videos insertObject:video atIndex:0];
    //[self.videos addObject:video];
}


@end

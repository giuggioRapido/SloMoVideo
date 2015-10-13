//
//  Video.m
//  SloMoVideo
//
//  Created by Chris on 10/2/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "Video.h"

@implementation Video

@synthesize duration = _duration;

- (NSString*) duration
{
    CMTime durationV = self.asset.duration;
    NSUInteger dTotalSeconds = CMTimeGetSeconds(durationV);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    
    NSString *videoDurationText = [NSString stringWithFormat:@" %lu:%02lu:%02lu",(unsigned long)dHours, (unsigned long)dMinutes, (unsigned long)dSeconds];
    
    _duration = videoDurationText;
    return _duration;
}

- (void) setDuration:(NSString *)duration
{
    _duration = duration;
}

- (void) createThumbnail
{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]
                                             initWithAsset:self.asset];
    
    //    Float64 durationSeconds = CMTimeGetSeconds(self.asset.duration);
    
    /// Pass in either startpoint or midpoint depending on where you want the thumbnail to come from
    CMTime startpoint = CMTimeMakeWithSeconds(0.0, 600);
    //        CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        
        /// Orientation needs to be changed because (for some reason) if not done, the thumbnails come out rotated 90 degrees
        UIImage *unresizedImage = [[UIImage alloc] initWithCGImage:image
                                                             scale:1.0
                                                       orientation:UIImageOrientationRight];
        
        /// Resize the image and assign to video thumbnail
        self.thumbnail = [unresizedImage resizedImageWithScaleFactor:0.1];
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:startpoint]] completionHandler:handler];
    
}

@end

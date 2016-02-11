//
//  MediaLibrary.m
//  SloMoVideo
//
//  Created by Chris on 10/9/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "MediaLibrary.h"

@implementation MediaLibrary

+ (id)sharedLibrary
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


- (void)initialPullFromDocuments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];

    if (directoryContent.count > 0) {
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
            
            if ([video.stringPath hasSuffix:@"30.mov"]) {
                video.fps = @"@30";
            }
            
            else if ([video.stringPath hasSuffix:@"60.mov"]) {
                video.fps = @"@60";
            }
            
            else if ([video.stringPath hasSuffix:@"120.mov"]) {
                video.fps = @"@120";
            }
            
            else if ([video.stringPath hasSuffix:@"240.mov"]) {
                video.fps = @"@240";
            }
            
            else {
                video.fps = nil;
            }
            
            [video createThumbnail];
            
            [self.videos addObject:video];
        }
    }
}

- (void)pullMostRecentFile
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
    
    if ([video.stringPath hasSuffix:@"30.mov"]) {
        video.fps = @"@30";
    }
    
    else if ([video.stringPath hasSuffix:@"60.mov"]) {
        video.fps = @"@60";
    }
    
    else if ([video.stringPath hasSuffix:@"120.mov"]) {
        video.fps = @"@120";
    }
    
    else if ([video.stringPath hasSuffix:@"240.mov"]) {
        video.fps = @"@240";
    }
    
    else {
        video.fps = nil;
    }
    
    [video createThumbnail];
    
    /// Because we want the videos array to be newest->oldest, we insert video at index 0. If we want it the other way, just simply call addObject instead.
    [self.videos insertObject:video atIndex:0];
    //    [self.videos addObject:video];
}

- (void)deleteVideo:(Video*)videoToDelete
{
    /// When video is deleted, remove the video from array and trip bool which will be used in Library VC
    /// to determine if the collection view should be reloaded.
    /// Then delete the original file from Documents.
    
    [self.videos removeObject:videoToDelete];
    self.videoWasDeleted = YES;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = videoToDelete.stringPath;
    NSError *error = nil;
    
    if (![fileManager removeItemAtPath:filePath error:&error]) {
        NSLog(@"[Error] %@ (%@)", error, filePath);
    } else {
        NSLog(@"Video deleted");
    }
}

- (void)deleteBatchOfVideos:(NSArray<Video*> *)arrayToDelete
{
    for (Video *video in arrayToDelete) {
        [self deleteVideo:video];
    }
}

/// To do: Generate video.fps dynamically

@end

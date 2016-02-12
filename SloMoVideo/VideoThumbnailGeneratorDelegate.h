//
//  VideoThumbnailGeneratorDelegate.h
//  SloMoVideo
//
//  Created by Chris on 2/11/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoThumbnailGeneratorDelegate <NSObject>

- (void)thumbnailWasGeneratedForVideo:(id) video;

@end

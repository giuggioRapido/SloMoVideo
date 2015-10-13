//
//  Model.h
//  SloMoVideo
//
//  Created by Chris on 10/9/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"
@import AVFoundation;
@import UIKit;
#import "UIImage+Resize.h"

@interface Model : NSObject

@property(strong, nonatomic) NSMutableArray *videos;
@property (nonatomic) NSUInteger videosCountForKVO;

+ (id)sharedModel;
- (void) initialPullFromDocuments;
- (void) pullMostRecentFile;

@end

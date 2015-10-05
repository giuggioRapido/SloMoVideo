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

-(void) setDuration:(NSString *)duration
{
    _duration = duration;
}


@end

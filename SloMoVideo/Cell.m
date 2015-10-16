//
//  Cell.m
//  SloMoVideo
//
//  Created by Chris on 10/1/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (void)select
{
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [UIColor redColor].CGColor;
}
- (void)deselect
{
    self.layer.borderWidth = 0.0;
    self.layer.borderColor = nil;
}

@end

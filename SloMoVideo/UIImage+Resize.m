//
//  UIImage+Resize.m
//  SloMoVideo
//
//  Created by Chris on 10/7/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *) resizedImageWithScaleFactor: (CGFloat) scaleFactor
{
    CGSize size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    BOOL hasAlpha = NO;
    CGFloat scale = 0.0;
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale);
    
    [self drawInRect:(CGRectMake(0.0, 0.0, size.width, size.height))];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end

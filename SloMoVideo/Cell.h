//
//  Cell.h
//  SloMoVideo
//
//  Created by Chris on 10/1/15.
//  Copyright © 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

- (void)select;
- (void)deselect;


@end

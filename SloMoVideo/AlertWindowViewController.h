//
//  AlertWindowViewController.h
//  SloMoVideo
//
//  Created by Chris on 1/6/16.
//  Copyright © 2016 Prince Fungus. All rights reserved.
//

/// This class is used as the root view controller for new windows created for WindowedAlertControllers. Its sole function is to act as the delegate for any textfields in the alerts. 

#import <UIKit/UIKit.h>

@interface AlertWindowViewController : UIViewController <UITextFieldDelegate>

@end

//
//  notifyMainViewController.h
//  Help!
//
//  Created by Jad Yacoub on 2/26/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>

@class contact;


@interface notifyMainViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

/* All objects created via storyboard will be created as weak objects */
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

/* Any object created manually needs to be declared as strong */
@property (strong, nonatomic)CLLocation *recentLocation;
@property (strong, nonatomic)NSString *selectedEmergency;


- (IBAction)helpButtonPressed:(UIButton *)sender;

@end

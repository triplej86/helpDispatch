//
//  helpMessagesTableViewController.h
//  Help!
//
//  Created by Jad Yacoub on 3/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface helpMessagesTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *helpMessages;
@property (nonatomic, strong) UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

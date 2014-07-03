//
//  settingsDetailViewController.h
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class contactsDataController;

@interface settingsDetailViewController : UITableViewController <UITableViewDataSource, ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate>

/* Make it strong to retain when switching to done*/
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (strong, nonatomic) contactsDataController *contactsList;

@end

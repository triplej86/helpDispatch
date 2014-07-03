//
//  settingsMasterViewController.h
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>

@interface settingsMasterViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *text911Switch;
@property (strong, nonatomic) NSMutableArray *supported_locations;


@end

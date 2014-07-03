//
//  settingsMasterViewController.m
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "settingsViewController.h"
#import "sharedLocationManagerSingleton.h"
#import "settingsDetailViewController.h"
#import "location.h"

#define dbFilename @"supported_locations.sql"

@interface settingsMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation settingsMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

     NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if([user boolForKey:@"911"] == YES){
        [self.text911Switch setOn:YES];
    }
    else{
        [self.text911Switch setOn:NO];
    }
    
    
    if([user boolForKey:@"location"] == YES){
        [self.locationSwitch setOn:YES];
    }
    else{
        [self.locationSwitch setOn:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (IBAction)locationSwitchPressed:(UISwitch *)sender {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if(self.locationSwitch.on){
        /* Check if Location services is enabled */
        if( [CLLocationManager locationServicesEnabled] == YES){
            [[sharedLocationManagerSingleton sharedSingleton].locationManager startUpdatingLocation];
            [user setBool:YES forKey:@"location"];
        }
        else{
            /* Save the location in Defaults as not enabled */
            [user setBool:NO forKey:@"location"];
            
            /* Display alert indicating location services are off*/
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle:@"Unable to Include Location"
                                    message:@"Location Services are disabled on device. Please enable them from the device settings first."
                                    delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil, nil];
            [message show];
            
            
            /* Set switch back to no */
            [self.locationSwitch setOn: NO];
        }
    }
    else{
        
        [[sharedLocationManagerSingleton sharedSingleton].locationManager stopUpdatingLocation ];
        [user setBool:NO forKey:@"location"];
    }
}


/********************************** Code to handle 911 texting Support ****************************************/

// Removing due to apple restriction, unable to release code that dispatches emergency services using core location framework
/*

- (IBAction)text911SwitchPressed:(id)sender {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if(self.text911Switch.on){
        [self isLocationBeingUpdated];
        
    }
    else{
        [user setBool:NO forKey:@"911"];
    }
}


- (void) isLocationBeingUpdated {
    
    // Check if locations servcies are on
    if( [CLLocationManager locationServicesEnabled] == NO){
        // Display alert indicating location services are off
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"Location Services are disabled on device!"
                                message:@"Unable to check if your area supports 911 texting. Please enable them from the device settings first and retry."
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil, nil];
        [message show];
        
        // Set switch back to no
        [self.text911Switch setOn: NO];
    }
    else{
        
        // Check if Location switch is on
        if( ![self.locationSwitch isOn]){
            // Location switch isn't on, so we aren't getting locations
            [[sharedLocationManagerSingleton sharedSingleton].locationManager startUpdatingLocation];
        }
        
        // check if current locations supports 911 texting
        [self locationSupportsTexting911];
    }
    
}


- (void) locationSupportsTexting911{
    
    // Read from database into local array
    sqlite3 *database;
    self.supported_locations = [[NSMutableArray alloc] init];
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath]
                                    stringByAppendingPathComponent:@"supported_locations.sql"];
        
    
    if(sqlite3_open( [databasePathFromApp UTF8String], &database) == SQLITE_OK){
        const char *sqlStatment = "select * from locations";
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(database, sqlStatment, -1, &compiledStatement, NULL) == SQLITE_OK){
            
            while (sqlite3_step(compiledStatement) == SQLITE_ROW){
                NSString *state = [NSString stringWithUTF8String:(char*) sqlite3_column_text(compiledStatement,0)];
                
                NSString *county;
                if(sqlite3_column_text(compiledStatement, 1) != NULL){
                    county = [NSString stringWithUTF8String:(char*) sqlite3_column_text(compiledStatement,1)];
                }
                
                NSString *city;
                if(sqlite3_column_text(compiledStatement,2) != NULL ){
                    city = [NSString stringWithUTF8String:(char*) sqlite3_column_text(compiledStatement,2)];
                }
                
                location *current_location = [[location alloc] initWithState:state county:county city:city];
                
                [self.supported_locations addObject:current_location];
                
                NSLog(@"Added state: %@, county %@, city %@\n", current_location.state, current_location.county,
                      current_location.city);
                
            }
        }
    }
    
    [self geocodeCurrentLocation];
}

// Get geocoded location from Location Manager Singelton and geocode it
- (void)geocodeCurrentLocation{

    CLLocation *locationCoordinates = [sharedLocationManagerSingleton sharedSingleton].recentLocation;
    
    location *currentLocation = [location alloc];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
     
    [geocoder reverseGeocodeLocation:locationCoordinates completionHandler:^(NSArray *placemarks, NSError *error){
        if(error == nil){
            if([placemarks count] > 0){
                CLPlacemark *placemark = placemarks[0];
                
                if(placemark.country){
                    if(![placemark.country isEqualToString:@"United States"]){
                        // Not in USA, not supported
                        [self texting911NotSupported];
                        return;
                    }
                }
                if(placemark.administrativeArea){
                    currentLocation.state = placemark.administrativeArea;
                }
                else{
                    [self printLocationError];
                    return;
                }
                if(placemark.subAdministrativeArea){
                    currentLocation.county = placemark.subAdministrativeArea;
                }
                else{
                    [self printLocationError];
                    return;
                }
                if(placemark.locality){
                    currentLocation.city = placemark.locality;
                }
                else{
                    [self printLocationError];
                    return;
                }
            }
            else{
                [self printLocationError];
                return;
            }
            [self checkIfSupported:currentLocation];
        }
        else{
            [self printLocationError];
            return;
        }
     }];

}


- (void) checkIfSupported: (location *) currentLocation {
    // Have supported locations and current location, now check if is supported
    location *supportedLocation;
    NSLog(@"Checking if Current state is %@, county %@, city %@", currentLocation.state, currentLocation.county, currentLocation.city);
    
    for(supportedLocation in self.supported_locations){
        // states match, check county
        if([supportedLocation.state isEqualToString:currentLocation.state] ){
            
            NSLog(@"State matches");
            
            // All of the state is supported
            if(supportedLocation.county == nil){
                NSLog(@"All of state is supported");
                [self texting911Supported];
                return;
            }
            // counties match, check cities
            else if( [supportedLocation.county isEqualToString:currentLocation.county] ){
                
                NSLog(@"County matches");
                
                // All of county is supported
                if(supportedLocation.city == nil){
                    NSLog(@"All of county is supported");
                    [self texting911Supported];
                    return;
                }
                // cities match
                else if( [supportedLocation.city isEqualToString:currentLocation.city]){
                    NSLog(@"City matches");
                    [self texting911Supported];
                    return;
                }
            }
        }
    }
    // Finished the loop with no matching record, thus not supported
    [self texting911NotSupported];
}

- (void)texting911NotSupported {
    
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Current Location does NOT support 911 texting!"
                            message:@"Check back again at a later time! By the end of 2014, this feature will be available everywhere in the United States"
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil, nil];
    [message show];
    
    [self.text911Switch setOn:NO];
    
    if( ![self.locationSwitch isOn]){
        // Location switch isn't on, so we aren't getting locations
        [[sharedLocationManagerSingleton sharedSingleton].locationManager stopUpdatingLocation];
    }
}

- (void)texting911Supported{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
 
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Current Location Supports 911 texting!"
                            message:@""
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil, nil];
    [message show];
    
    [user setBool:YES forKey:@"911"];
    
    if( ![self.locationSwitch isOn]){
        // Location switch isn't on, so we aren't getting locations
        [[sharedLocationManagerSingleton sharedSingleton].locationManager stopUpdatingLocation];
    }
    
}

-(void)printLocationError {
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Unable to obtain your geocoded Location!"
                            message:@"Please confirm with FCC whether 911 texting is available in your area."
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil, nil];
    [message show];

    if( ![self.locationSwitch isOn]){
        // Location switch isn't on, so we aren't getting locations
        [[sharedLocationManagerSingleton sharedSingleton].locationManager stopUpdatingLocation];
    }
}
*/
@end

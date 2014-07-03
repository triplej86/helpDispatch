//
//  notifyMainViewController.m
//  Help!
//
//  Created by Jad Yacoub on 2/26/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "notifyMainViewController.h"
#import "sharedLocationManagerSingleton.h"
#import "contact.h"

#define DEFAULT_MESSAGE_1 @"I am being chased by a stranger!"
#define DEFAULT_MESSAGE_2 @"My house is being broken into!"
#define DEFAULT_MESSAGE_3 @"I am in a medical emergency!"
#define DEFAULT_MESSAGE_4 @"I am in a car accident!"

@interface notifyMainViewController ()
@property UIActivityIndicatorView *activityIndicator;
@end

@implementation notifyMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableArray *helpMessages = [[NSMutableArray alloc] init];
    
    if([user objectForKey:@"helpMessages"] != nil){
        helpMessages = [[user objectForKey:@"helpMessages"] mutableCopy];
    }
    else{
        /* Empty, then use default messages */
        helpMessages = [NSMutableArray arrayWithObjects: DEFAULT_MESSAGE_1, DEFAULT_MESSAGE_2, DEFAULT_MESSAGE_3, DEFAULT_MESSAGE_4, nil];
        [user setObject:helpMessages forKey:@"helpMessages"];
    }
    
    
    if( [user objectForKey:@"location"] == nil){
        /* Check if Location services are enabled */
        if( [CLLocationManager locationServicesEnabled] == YES){
            [user setBool:YES forKey:@"location"];
            /* Start updating locations*/
            [[sharedLocationManagerSingleton sharedSingleton].locationManager startUpdatingLocation];
        }
        else{
            /* Set no and display alert */
            [user setBool:NO forKey:@"location"];
            
            /* Display alert indicating location services are off*/
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle:@"Unable to Include Location"
                                    message:@"Location Services are disabled on device. Please enable them from the device settings first."
                                    delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil, nil];
            [message show];
        }

    }
    
    if( [user boolForKey:@"location"] == YES){
        /* Start updating location */
        [[sharedLocationManagerSingleton sharedSingleton].locationManager startUpdatingLocation];
    }
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:   UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setColor: [UIColor redColor] ];
    
    UIBarButtonItem *itemIndicator = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    [self.navigationItem setLeftBarButtonItem:itemIndicator];

    self.selectedEmergency = [[NSString alloc]init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)unwindToAlertView:(UIStoryboardSegue *)unwindSegue
{

}


/* Checks if contact list or 911 is disabled
 * Checks if messaging is available on device
 * Starts alert sequence
 */
- (IBAction)helpButtonPressed:(UIButton *)sender {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if( ([[user objectForKey:@"contactList"] count] == 0) &&
        ([user boolForKey:@"911"] == NO) ){
        /* Display Alert that contact list is empty*/
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"Contact List is Empty"
                                message:@"Please add contacts to alert and try again!"
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil, nil];
        [message show];
    }
    else{
        
        if([MFMessageComposeViewController canSendText] == NO){
            
            UIAlertView *message = [[UIAlertView alloc]
                                    initWithTitle:@"Text Messaging is disabled on the System"
                                    message:@"Please Enable text messaging first and try again"
                                    delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil, nil];
            [message show];
        }
        else{
    
            [self.activityIndicator startAnimating];
        
            [self displayHelpEmergencyAlert];
        }
        
    }
}

- (void) displayHelpEmergencyAlert{
    
    NSArray *helpMessages = [[NSArray alloc]init];
    NSString *helpMessage = [[NSString alloc]init];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    helpMessages = [[user objectForKey:@"helpMessages"] mutableCopy];
    
    /* Display Alert */
    UIActionSheet *message = [[UIActionSheet alloc]
                              initWithTitle:@"What is your Emergency?"
                              delegate:self
                              cancelButtonTitle:@"Do not specify emergency"
                              destructiveButtonTitle:@"Cancel alert"
                              otherButtonTitles:nil, nil];
    
    for (helpMessage in helpMessages){
        [message addButtonWithTitle:helpMessage];
    }
    
    [message showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if(buttonIndex == 0){
        [self.activityIndicator stopAnimating];
    }
    else if(buttonIndex == 1){
        self.selectedEmergency = @"";
        [self performSelector:@selector(startAlertSequence) withObject:self afterDelay:1];
    }
    else{
        self.selectedEmergency = [popup buttonTitleAtIndex:buttonIndex];
        [self performSelector:@selector(startAlertSequence) withObject:self afterDelay:1];
    }
    
}

/* Prepares the message to be sent
 * Does a lot of error checking and gets the GEO location if location is enabled
 * It then calls the sendAlerts methods that does the actualy message sending
 */
-(void) startAlertSequence{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    /* Get recent Location from Location Manager Singleton */
    self.recentLocation = [sharedLocationManagerSingleton sharedSingleton].recentLocation;

   /* Prepare the message */
    NSMutableString *body = [NSMutableString stringWithString:@"I need help! "];
    [body appendString:self.selectedEmergency];
    [body appendString:@"\n"];
    
    /* Check if Location is on, if on Get Location and convert to Address & add to message*/
    if( ([user boolForKey:@"location"] == YES) && [self locationOK])  {
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
                
        [geocoder reverseGeocodeLocation:self.recentLocation completionHandler:^(NSArray *placemarks, NSError *error){
        if(error == nil){
            if([placemarks count] > 0){
                CLPlacemark *placemark = placemarks[0];

                NSMutableString *currentGeoLocation = [NSMutableString stringWithFormat:@"I am around "];
                            
                if(placemark.subThoroughfare){
                    [currentGeoLocation appendString: placemark.subThoroughfare];
                    [currentGeoLocation appendString:@" "];
                }
                            
                if(placemark.thoroughfare){
                    [currentGeoLocation appendString:placemark.thoroughfare];
                    [currentGeoLocation appendString:@" "];
                }
                            
                [currentGeoLocation appendString:placemark.locality];
                [currentGeoLocation appendString:@" "];
                [currentGeoLocation appendString:placemark.administrativeArea];
                            
                [body appendString:currentGeoLocation];
            }
        }
        /* Add the map location http://maps.google.com/maps?q=[Title]@[Lat,Lon]*/
        NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/?q=%f,%f",
                         self.recentLocation.coordinate.latitude, self.recentLocation.coordinate.longitude];

        [body appendString:@"\nMy map location:\n"];
        [body appendString:url];
                    
        [self sendAlerts:body];

        }];
    }
    else{
        [self sendAlerts:body];
    }
    
}

/* Present the sms view */
- (void)sendAlerts:(NSMutableString *) body{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
   
    NSString *subject = @"Need Help!";
    
    NSLog(@"The current body message is %@", body);
    
    MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc]init];
    mc.messageComposeDelegate = self;
            
    NSMutableArray *to = [[NSMutableArray alloc] init];
            
    /* Get for phone numbers and add them to send to list*/
    for (NSData *encodedContact in [user objectForKey:@"contactList"]){
         contact *currentContact = [NSKeyedUnarchiver unarchiveObjectWithData:encodedContact];
         [to addObject:currentContact.phoneNumber];
    }
            
    if([user boolForKey:@"911"] == YES){
        [to addObject:@"911"];
    }

    [mc setSubject:subject];
    [mc setBody:body];
    [mc setRecipients: (NSArray *)to];
            
    [self presentViewController:mc animated:YES completion:NULL];
    
    [self.activityIndicator stopAnimating];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{

    [self.activityIndicator stopAnimating];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
     /* Display an alert saying, Help is on its way */
    if (result == MessageComposeResultSent){
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"Message sent!"
                                message:@"Help is on the way!"
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil, nil];
        [message show];
    }
   
}

- (BOOL) locationOK {
    
    if([sharedLocationManagerSingleton sharedSingleton].locationError == YES){
        return NO;
    }
    else{
        return YES;
    }
}

@end

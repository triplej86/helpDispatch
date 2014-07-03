//
//  sharedLocationManagerSingleton.m
//  Help!
//
//  Created by Jad Yacoub on 5/17/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "sharedLocationManagerSingleton.h"

@implementation sharedLocationManagerSingleton

@synthesize locationManager;

- (id)init {
    self = [super init];
    
    if(self) {
        self.recentLocation = [[CLLocation alloc] init];
        self.locationManager = [CLLocationManager new];
        [self.locationManager setDelegate:self];

        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
        [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
        self.locationError = YES;
    }
    
    return self;
}

+ (sharedLocationManagerSingleton*)sharedSingleton {
    static sharedLocationManagerSingleton* sharedSingleton;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [sharedLocationManagerSingleton new];
        }
    }
    
    return sharedSingleton;
}

/* Delegate methods for location manager */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    NSLog(@"Updated Location");
    self.recentLocation = [locations lastObject];
    self.locationError = NO;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{

    [self setLocationError:YES];
    
    NSLog(@"error%@",error);
    switch([error code])
    {
        case kCLErrorNetwork:
        {
            /* No network or in airplane mode */
            NSLog(@"No Network or in airplane mode");
        }
        break;
        case kCLErrorDenied:
        {
            NSLog(@"User denied location manager");
        }
        break;
        default:
        {
            NSLog(@"Other Error");
        }
        break;
    }
}





@end



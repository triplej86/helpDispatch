//
//  sharedLocationManagerSingleton.h
//  Help!
//
//  Created by Jad Yacoub on 5/17/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface sharedLocationManagerSingleton : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *recentLocation;
@property (nonatomic, assign) BOOL locationError;


+ (sharedLocationManagerSingleton*) sharedSingleton;


@end

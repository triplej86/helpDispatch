//
//  location.m
//  Help!
//
//  Created by Jad Yacoub on 5/14/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "location.h"

@implementation location

-(id)initWithState:(NSString *)state county: (NSString *)county city: (NSString *)city{
  
    self = [super init];
    
    if(self){
        _state = state;
        _county = county;
        _city = city;
        return self;
    }
    return nil;
}

@end

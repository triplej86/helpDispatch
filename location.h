//
//  location.h
//  Help!
//
//  Created by Jad Yacoub on 5/14/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface location : NSObject

-(id)initWithState:(NSString *)state county: (NSString *)county city: (NSString *)city;

@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *county;
@property (nonatomic, copy) NSString *city;

@end

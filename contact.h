//
//  contact.h
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

/* Data Model */

#import <Foundation/Foundation.h>

@interface contact : NSObject <NSCoding>

/* This is done because these objects will be used in other classes, to avoid having two objects change these values, we make them copy. Similar as pass by value in c*/
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phoneNumber;

-(id)initWithName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber;
-(BOOL)isEqual:(contact *)contactToCompare;

@end

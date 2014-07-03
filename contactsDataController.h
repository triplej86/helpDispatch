//
//  contactsDataController.h
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class contact;

@interface contactsDataController : NSObject

/* Copy is needed here since when */
@property (nonatomic, copy) NSMutableArray *contactList;

-(NSUInteger) countOfContactList;
-(contact *)objectInContactListAtIndex:(NSUInteger)index;
-(void) addToContactListWithContact:(contact *)contact;
-(void) removeContactAtIndex:(NSUInteger) index;

@end

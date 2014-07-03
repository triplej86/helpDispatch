//
//  contactsDataController.m
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "contactsDataController.h"
#import "contact.h"


@interface contactsDataController()

-(void)initializeDefaultContactList;

@end


@implementation contactsDataController

-(void)initializeDefaultContactList{
    NSMutableArray *contactList = [[NSMutableArray alloc]init];
    self.contactList = contactList;
}

-(id) init{
    
    if (self = [super init]){
        [self initializeDefaultContactList];
        return self;
    }
    return nil;
}

/* This is done to gaurantee that the setter creates a mutable array */
-(void)setContactList:(NSMutableArray *)newContactList{
    
    if(_contactList != newContactList ){
        _contactList = [newContactList mutableCopy];
    }
    
}

-(NSUInteger) countOfContactList{
    return [self.contactList count];
}

-(contact *)objectInContactListAtIndex:(NSUInteger)index{
    
    if( [self.contactList count] == 0 ){
        return nil;
    }
    else if( [self.contactList count] < index + 1){
        return nil;
    }
    else{
        return [self.contactList objectAtIndex:index];
    }

}

-(void) addToContactListWithContact:(contact *)contact{
    [self.contactList addObject:contact];
}

-(void) removeContactAtIndex:(NSUInteger) index{
    [self.contactList removeObjectAtIndex:index];
}


@end

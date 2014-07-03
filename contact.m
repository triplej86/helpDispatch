//
//  contact.m
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "contact.h"

@implementation contact

- (BOOL)isEqual:(contact *)contactToCompare{
    if( [self.firstName isEqualToString:contactToCompare.firstName]
        && [self.lastName isEqualToString:contactToCompare.lastName]
       && [self.phoneNumber isEqualToString:contactToCompare.phoneNumber]){
        return YES;
    }
    else{
         return NO;
    }
    
}

-(id)initWithName:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber{
    self = [super init];
    
    if(self){
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
        return self;
    }
    return nil;
}



/*********** Protocol for encoding the data *****************/
-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.phoneNumber forKey:@"phone"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self)
        _firstName = [decoder decodeObjectForKey:@"firstName"];
        _lastName = [decoder decodeObjectForKey:@"lastName"];
        _phoneNumber = [decoder decodeObjectForKey:@"phone"];
    return self;
}


@end

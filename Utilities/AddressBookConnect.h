//
//  NSObject+AddressBookConnect.h
//  CMCMobileSec
//
//  Created by Nam on 1/2/13.
//  Copyright (c) 2013 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddressBookConnect:NSObject

+(void)addToAddressbook;
+(NSMutableArray*) getAllContactData;
+ (void) addNewContactToAddressBook :(NSString*) name :(NSString*[]) phone :(NSString*[]) email;

@end

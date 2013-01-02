//
//  AddressBookConnect.m
//  CMCMobileSec
//
//  Created by Nam on 1/2/13.
//  Copyright (c) 2013 CMC. All rights reserved.
//

#import "AddressBookConnect.h"

@implementation AddressBookConnect{
    
}

+(void)addToAddressbook{
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
                                                               
                                                               kCFAllocatorDefault,
                                                               
                                                               CFArrayGetCount(people),
                                                               
                                                               people
                                                               
                                                               );
    
    
    ABUnknownPersonViewController *unknownPersonViewController = [[ABUnknownPersonViewController alloc] init];
    unknownPersonViewController.displayedPerson = (ABRecordRef)[self buildContactDetails];
    unknownPersonViewController.allowsAddingToAddressBook = YES;
}

+ (ABRecordRef)buildContactDetails {
    
    NSLog(@"building contact details");
    ABRecordRef person = ABPersonCreate();
    CFErrorRef  error = NULL;
    
    // firstname
    ABRecordSetValue(person, kABPersonFirstNameProperty, @"Don Juan", NULL);
    
    // email
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, @"expert.in@computer.com", CFSTR("email"), NULL);
    ABRecordSetValue(person, kABPersonEmailProperty, email, &error);
    CFRelease(email);
    
    // Start of Address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
    [addressDict setObject:@"The awesome road numba 1" forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDict setObject:@"0568" forKey:(NSString *)kABPersonAddressZIPKey];
    [addressDict setObject:@"Oslo" forKey:(NSString *)kABPersonAddressCityKey];
    ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
    ABRecordSetValue(person, kABPersonAddressProperty, address, &error);
   // [addressDict release];
    CFRelease(address);
    // End of Address
    
    if (error != NULL)
        NSLog(@"Error: %@", error);
    
   // [(id)person autorelease];
    return person;
}

+(NSMutableArray *) getAllContactData {
    
    NSMutableArray* contact_db = [NSMutableArray array];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    for( int i = 0 ; i < n ; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSLog(@"firstName %@", firstName);
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSLog(@"lastName %@", lastName);
        
        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        
        
        ABMultiValueRef *phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        NSString *phone_data[ABMultiValueGetCount(phones)];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            //CFRelease(phones);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            CFRelease(phoneNumberRef);
            NSLog(@"  - %@", phoneNumber);
            
            phone_data[j] = phoneNumber;
      
        }
        
        ABMultiValueRef *emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
        
        NSString *email_data[ABMultiValueGetCount(emails)];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(emails); j++)
        {
            
            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emails, j);
            //CFRelease(phones);
            NSString *email = (__bridge NSString *)emailRef;
            CFRelease(emailRef);
            NSLog(@"  - %@", email);
            
            email_data[j] = email;
            
        }
        
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setObject:name forKey:@"name"];
        [item setObject:*phone_data forKey:@"phone"];
        [item setObject:*email_data forKey:@"email"];
        [contact_db addObject:item];
        
      //  [self addNewContactToAddressBook:name :*phone_data :*email_data];
        
    }
    
    
    
    return contact_db;
}

+ (void) addNewContactToAddressBook :(NSString*) name :(NSString*[]) phone :(NSString*[]) email {
    
    ABAddressBookRef libroDirec = ABAddressBookCreate();
    
    ABRecordRef persona = ABPersonCreate();
    
    ABRecordSetValue(persona, kABPersonFirstNameProperty, @"Nam 123", nil);
    
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    bool didAddPhone = ABMultiValueAddValueAndLabel(multiPhone, @"12345678", kABPersonPhoneMobileLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"097", kABPersonPhoneMobileLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, @"098", kABPersonPhoneMobileLabel, NULL);
    
    if(didAddPhone){
        
        ABRecordSetValue(persona, kABPersonPhoneProperty, multiPhone,nil);
        
        NSLog(@"Phone Number saved......");
        
    }
    
    CFRelease(multiPhone);
    
    //##############################################################################
    
    ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
    
    bool didAddEmail = ABMultiValueAddValueAndLabel(emailMultiValue, @"123@gmail.com", kABOtherLabel, NULL);
    
    if(didAddEmail){
        
        ABRecordSetValue(persona, kABPersonEmailProperty, emailMultiValue, nil);
        
        NSLog(@"Email saved......");
    }
    
    CFRelease(emailMultiValue);
    
    //##############################################################################
    
    ABAddressBookAddRecord(libroDirec, persona, nil);
    
    CFRelease(persona);
    
    ABAddressBookSave(libroDirec, nil);
    
    CFRelease(libroDirec);
    
    NSString * errorString = [NSString stringWithFormat:@"Information are saved into Contact"];
    
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"New Contact Info" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [errorAlert show];
    
   // [errorAlert release];
}

@end

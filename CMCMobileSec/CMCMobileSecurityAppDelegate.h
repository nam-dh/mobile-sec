//
//  CMCMobileSecurityAppDelegate.h
//  CMCMobileSec
//
//  Created by Duc Tran on 11/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

extern NSString* sessionKey;
extern int accountType;
extern NSString* email;
extern NSString* password;
extern NSString* imei;

@interface CMCMobileSecurityAppDelegate : UIResponder <UIApplicationDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) showPopUp:(NSTimer *) timer;

+ (void) copyDatabaseIfNeeded;
+ (NSString *) getDBPath;
+(int) checkUserData:(NSString *)dbPath ;
+(void) getUserData:(NSString *)dbPath;
+(NSString*) getEmail:(NSString *)dbPath ;
+(NSString*) getPassword:(NSString *)dbPath ;

@end

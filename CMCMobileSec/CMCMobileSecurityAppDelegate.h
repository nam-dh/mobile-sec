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
<<<<<<< HEAD
extern NSString* imei;
=======
extern NSMutableArray* gItemToScan;
>>>>>>> 6c55a5a191dae73fb9b644149d73abb4e541b558

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

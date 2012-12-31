//
//  CMCMobileSecurityAppDelegate.h
//  CMCMobileSec
//
//  Created by Duc Tran on 11/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>

extern NSString* sessionKey;
extern int accountType;
extern NSString* email;
extern NSString* password;
extern NSMutableArray* gItemToScan;
extern NSMutableArray* gScanHistory;
extern NSString *deviceID;
extern NSString *tokenKey;
extern NSString *md5hash;
extern NSString *downloadFile;
extern Boolean login;
extern NSString* blackListSwitchValue, *keyWordSwitchValue, *keepConnectSwitchValue ,*remoteLockSwitchValue, *remoteTrackSwitchValue, *backupDataSwitchValue, *remoteBackupSwitchValue, *remoteClearSwitchValue, *remoteRestoreSwitchValue;

@interface CMCMobileSecurityAppDelegate : UIResponder <UIApplicationDelegate, NSXMLParserDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;

- (void) requestServer:(NSTimer *) timer;



@end

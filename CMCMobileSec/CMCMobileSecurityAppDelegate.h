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
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "MailSender.h"

extern int accountType;
extern NSMutableArray* gItemToScan;
extern NSMutableArray* gScanHistory;
extern NSString *downloadFile;
extern NSString* blackListSwitchValue, *keyWordSwitchValue, *keepConnectSwitchValue ,*remoteLockSwitchValue, *remoteTrackSwitchValue, *backupDataSwitchValue, *remoteBackupSwitchValue, *remoteClearSwitchValue, *remoteRestoreSwitchValue;
extern NSString *language;
extern AVCaptureStillImageOutput *stillImageOutput;
extern AVCaptureSession *session;


@interface CMCMobileSecurityAppDelegate : UIResponder <UIApplicationDelegate, NSXMLParserDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;


- (void)doCapture;
- (void) requestServer:(NSTimer *) timer;



@end

//
//  CMCMobileSecurityAppDelegate.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "CMCMobileSecurityAppDelegate.h"
#import "ServerConnection.h"
#import "DataBaseConnect.h"
#import "NSData+MD5.h"
#import "FileDecryption.h"
#import "NSData+Base64.h"
#import "ServerResponePraser.h"

@implementation CMCMobileSecurityAppDelegate {
    NSMutableData *responeData;
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    UIImage *image = [UIImage imageNamed:@"bar_normal.png"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackingLocation) name:@"trackingLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTrackingLocation) name:@"stopTrackingLocation" object:nil];
    

    //load settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    blackListSwitchValue = [defaults objectForKey:@"blackListSwitchValue"];
    keyWordSwitchValue = [defaults objectForKey:@"keyWordSwitchValue"];
    keepConnectSwitchValue= [defaults objectForKey:@"keepConnectSwitchValue"];

    remoteLockSwitchValue= [defaults objectForKey:@"remoteLockSwitchValue"];
    
    remoteTrackSwitchValue = [defaults objectForKey:@"remoteTrackSwitchValue"];

    backupDataSwitchValue= [defaults objectForKey:@"backupDataSwitchValue"];
    
    remoteBackupSwitchValue= [defaults objectForKey:@"remoteBackupSwitchValue"];
    
    remoteClearSwitchValue= [defaults objectForKey:@"remoteClearSwitchValue"];
    
    remoteRestoreSwitchValue= [defaults objectForKey:@"remoteRestoreSwitchValue"];
    
    language= [defaults objectForKey:@"language"];
    
    // prepare to history
    NSThread* prepareHistoryThread = [[NSThread alloc] initWithTarget:self
                                                           selector:@selector(prepareHistory) object:nil];
    [prepareHistoryThread start];
    
    [self testEncrypt];
    
    return YES;
}


-(void) testEncrypt{
    
    NSString* tokenkey_send = @"634925929652812500";
    
    
    NSString *report = @"<?xml version=\"1.0\" standalone=\"yes\"?>\r\n<Commands>\r\n  <Command>\r\n    <CmdKey>CMC_TRACK</CmdKey>\r\n    <CmdStatus>PROCESSING</CmdStatus>\r\n    <FinishTime>12/31/2012 15:41:55</FinishTime>\r\n    <ResultDetail>\r\n    </ResultDetail>\r\n    <LicKey1>\r\n    </LicKey1>\r\n    <LicKey2>\r\n    </LicKey2>\r\n    <LicKey3>\r\n    </LicKey3>\r\n  </Command>\r\n</Commands>";
    
    
    NSString* base64String = [ServerResponePraser encryptCmdData:report :tokenkey_send];
    
    NSData* data = nil;
    data = [NSData dataFromBase64String:base64String];
    NSString* data1 = [ServerResponePraser decryptCmdData:data :tokenkey_send];
    NSLog(@"data after =%@", data1);
    
    ServerConnection *serverConnect = [[ServerConnection alloc] init];
    
    [serverConnect uploadFile:base64String :@"cmd" :tokenkey_send :sessionKey];
}

-(int)getValueOfHex:(char)hex
{
    if (hex > 'a') return hex - 'a' + 10;
    else return hex - '0';
}

-(void) prepareHistory {
    if (gScanHistory == nil) {
        gScanHistory = [NSMutableArray array];
    }
    //load from database
    gScanHistory = [DataBaseConnect getScanStatistic:[DataBaseConnect getDBPath]];
    
    
}

//add observer

- (void)trackingLocation
{
    [locationManager startUpdatingLocation];
    
}
- (void)stopTrackingLocation
{
    [locationManager stopUpdatingLocation];
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) requestServer:(NSTimer *) timer {
    
    NSLog(@"keepConnectSwitchValue=%@",keepConnectSwitchValue);
    
    if ([keepConnectSwitchValue isEqualToString:@"ON"]) {
        
        if ((accountType == 2) && (login== false)){
            ServerConnection *theInstance = [[ServerConnection alloc] init];
            [theInstance userLogin:email :password :sessionKey];
        }
        
        if (login) {
            
            NSString *type = @"cmd";
            
            ServerConnection *theInstance = [[ServerConnection alloc] init];
            [theInstance downloadFile:sessionKey :type];
            
        }
        
    }
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    float latt = newLocation.coordinate.latitude;
    float longi = newLocation.coordinate.longitude;
    latt = 21.01;
    longi = 105.7981;
    
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    long lnumber = [timeStampObj longValue];
    
    NSString* vector = [NSString stringWithFormat:@"%ld:%f:%f", lnumber, latt, longi];

    ServerConnection *theInstance = [[ServerConnection alloc] init];
    [theInstance locationReport:vector :sessionKey];
}



@end

NSString* sessionKey;
int accountType = 1;
NSString* email = nil;
NSString* password = nil;
NSMutableArray * gItemToScan = nil;
NSMutableArray * gScanHistory = nil;
NSString *deviceID = @"123";
NSString *tokenKey = nil;
NSString *md5hash = nil;
NSString *downloadFile = nil;
Boolean login = false;
NSString* blackListSwitchValue = nil, *keyWordSwitchValue = nil , *keepConnectSwitchValue = nil,*remoteLockSwitchValue = nil, *remoteTrackSwitchValue = nil, *backupDataSwitchValue = nil, *remoteBackupSwitchValue = nil, *remoteClearSwitchValue = nil, *remoteRestoreSwitchValue = nil;

NSString *language = nil;

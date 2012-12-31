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

@implementation CMCMobileSecurityAppDelegate {
    NSMutableData *responeData;
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackingLocation) name:@"trackingLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTrackingLocation) name:@"stopTrackingLocation" object:nil];
    

    
    return YES;
}

//add observer

- (void)trackingLocation
{
    NSLog(@"tracking location");
    [locationManager startUpdatingLocation];
    
}
- (void)stopTrackingLocation
{
    NSLog(@"stop tracking location");
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
    
    if ((accountType == 2) && (login== false)){
        ServerConnection *theInstance = [[ServerConnection alloc] init];
        [theInstance userLogin:email :password :sessionKey];
    }
    
    NSString *type = @"cmd";
    
    ServerConnection *theInstance = [[ServerConnection alloc] init];
    [theInstance downloadFile:sessionKey :type];
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    float latt = newLocation.coordinate.latitude;
    float longi = newLocation.coordinate.longitude;
    latt = 21.0409;
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

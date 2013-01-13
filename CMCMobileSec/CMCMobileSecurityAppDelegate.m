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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDevice) name:@"lockDevice" object:nil];

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
    if (language == nil) {
        language = @"ENG";
    }
    
    // prepare to history
    NSThread* prepareHistoryThread = [[NSThread alloc] initWithTarget:self
                                                           selector:@selector(prepareHistory) object:nil];
    [prepareHistoryThread start];
    
    [self setupAVCapture];
    
    [self testEncrypt];
    
    return YES;
}


-(void) testEncrypt{
    
    NSString*tokenkey_send = @"1357637775056";
    NSString*path = @"/Users/nam/Desktop/files/.upload/1357637775056.enc";//put the path to your file here
    NSData* fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    NSString* cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
//
//    tokenkey_send = @"1357637835055";
//    path = @"/Users/nam/Desktop/files/.upload/1357637835055.enc";//put the path to your file here
//    fileData = [NSData dataWithContentsOfFile: path];
//    NSLog(@"fileData = %@", [fileData description]);
//    
//    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
//    
//    tokenkey_send = @"1357637895055";
//    path = @"/Users/nam/Desktop/files/.upload/1357637895055.enc";//put the path to your file here
//    fileData = [NSData dataWithContentsOfFile: path];
//    NSLog(@"fileData = %@", [fileData description]);
//    
//    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
}

-(void) testDecrypt{
    
    NSString* tokenkey_send = @"634932586993881250";
    NSString* password = @"123";
    
    NSString *path = @"/Users/nam/Desktop/files/.upload/634932586993881250.enc";//put the path to your file here
    NSData *fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    NSString* cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    tokenkey_send = @"634932587347318750";
    path = @"/Users/nam/Desktop/files/.download/634932587347318750.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    tokenkey_send = @"634932587947475000";
    path = @"/Users/nam/Desktop/files/.download/634932587947475000.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    tokenkey_send = @"634932588547006250";
    path = @"/Users/nam/Desktop/files/.download/634932588547006250.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    
    tokenkey_send = @"634932596347162500";
    path = @"/Users/nam/Desktop/files/.download/634932596347162500.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    
    tokenkey_send = @"634932597546693750";
    path = @"/Users/nam/Desktop/files/.download/634932597546693750.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    tokenkey_send = @"634932598147006250";
    path = @"/Users/nam/Desktop/files/.download/634932598147006250.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    tokenkey_send = @"634932598746537500";
    path = @"/Users/nam/Desktop/files/.download/634932598746537500.enc";//put the path to your file here
    fileData = [NSData dataWithContentsOfFile: path];
    NSLog(@"fileData = %@", [fileData description]);
    
    cmdString = [ServerResponePraser decryptCmdData:fileData :tokenkey_send :password ];
    
    
    
//    NSString* base64String = [ServerResponePraser encryptCmdData:report :tokenkey_send];
//    
//    NSData* data = nil;
//    data = [NSData dataFromBase64String:base64String];
//    NSString* data1 = [ServerResponePraser decryptCmdData:data :tokenkey_send];
//    NSLog(@"data after =%@", data1);
//    
//    ServerConnection *serverConnect = [[ServerConnection alloc] init];
//    
//    [serverConnect uploadFile:base64String :@"cmd" :tokenkey_send :sessionKey];
}

-(int)getValueOfHex:(char)hex
{
    if (hex >= 'a') return hex - 'a' + 10;
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

- (void) lockDevice
{
    //capture picture
    [self doCapture];
    
    //send mail
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/pic.jpg"];

    [[MailSender sharedMailSender] sendMailViaSMTP:email :pngPath];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
    
    if ([keepConnectSwitchValue isEqualToString:@"ON"]) {
        
        if ((accountType == 2) && (login== false)){
            if (sessionKey == nil) {
                ServerConnection *theInstance = [[ServerConnection alloc] init];
                [theInstance getsessionKey];
            } else {
                ServerConnection *theInstance = [[ServerConnection alloc] init];
                [theInstance userLogin:email :password :sessionKey];
            }
        }
        
        if (login) {
            
            NSString *type = @"cmd";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
            
            ServerConnection *theInstance = [[ServerConnection alloc] init];
            [theInstance downloadFile:sessionKey :type];
            
        }
        
    }
    
//    NSString* tokenkey_send = @"634930307604350000";
//    
//    NSString *path = @"/Users/nam/Desktop/result.xml";
//    
//    NSData *myData = [NSData dataWithContentsOfFile:path];
//    NSString* newStr = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
//    
//    NSString *report = @"<?xml version=\"1.0\" standalone=\"yes\"?>\r\n<Commands>\r\n  <Command>\r\n    <CmdKey>CMC_LOCATE</CmdKey>\r\n    <CmdStatus>PROCESSING</CmdStatus>\r\n    <FinishTime>1/6/2013 1:13:26</FinishTime>\r\n    <ResultDetail>\r\n    </ResultDetail>\r\n    <Cmdid>1213</Cmdid>\r\n  </Command>\r\n</Commands>";
//    
//    
//    NSString* base64String = [ServerResponePraser encryptCmdData:newStr :tokenkey_send];
//    
//    
//    ServerConnection *serverConnect = [[ServerConnection alloc] init];
//    // ServerConnection *theInstance = [[ServerConnection alloc] init];
//    [serverConnect userLogin:email :password :sessionKey];
//    
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        // code to be executed on main thread.If you want to run in another thread, create other queue
//        [serverConnect uploadFile:base64String :@"CMD" :tokenkey_send :sessionKey];
//    });
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    float latt = newLocation.coordinate.latitude;
    float longi = newLocation.coordinate.longitude;
    //latt = 21.01;
    //longi = 105.7981;
    
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    long lnumber = [timeStampObj longValue];
    
    NSString* vector = [NSString stringWithFormat:@"%ld:%f:%f", lnumber, latt, longi];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
    
    ServerConnection *theInstance = [[ServerConnection alloc] init];
    [theInstance locationReport:vector :sessionKey];
}

- (BOOL)setupAVCapture
{
    NSError *error = nil;
    
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // Select a video device, make an input
    AVCaptureDevice *device = [self frontFacingCameraIfAvailable];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
        return NO;
    if ([session canAddInput:input])
        [session addInput:input];
    
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    if ([session canAddOutput:stillImageOutput])
        [session addOutput:stillImageOutput];
    
    [session startRunning];
    
    return YES;
}

-(AVCaptureDevice *)frontFacingCameraIfAvailable{
    
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    
    for (AVCaptureDevice *device in videoDevices){
        
        if (device.position == AVCaptureDevicePositionFront){
            
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if (!captureDevice){
        
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (void)doCapture {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    NSLog(@"stillImageoutput: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *__strong error) {
                                                      // Do something with the captured image
                                                      CFDictionaryRef exifAttachments = CMGetAttachment( imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                      if (exifAttachments)
                                                      {
                                                          // Do something with the attachments.
                                                          NSLog(@"attachements: %@", exifAttachments);
                                                      }
                                                      else
                                                          NSLog(@"no attachments");
                                                      
                                                      NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                      UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                      [self imageToFile:image];
                                                  }];
    
}

-(void) imageToFile :(UIImage*)image{
    // Create paths to output images
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/pic.png"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/pic.jpg"];
    
    NSLog(@"PNG=%@", pngPath);
    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:jpgPath atomically:YES];
    
    // Write image to PNG
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    // Let's check to see if files were successfully written...
    
    // Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Point to Document directory
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // Write out the contents of home directory to console
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
}



@end

AVCaptureStillImageOutput *stillImageOutput;
int accountType = 1;
NSString* email = nil;
NSString* password = nil;
NSMutableArray * gItemToScan = nil;
NSMutableArray * gScanHistory = nil;
NSString *deviceID = @"123";
NSString *downloadFile = nil;
Boolean login = false;
NSString* blackListSwitchValue = nil, *keyWordSwitchValue = nil , *keepConnectSwitchValue = nil,*remoteLockSwitchValue = nil, *remoteTrackSwitchValue = nil, *backupDataSwitchValue = nil, *remoteBackupSwitchValue = nil, *remoteClearSwitchValue = nil, *remoteRestoreSwitchValue = nil;

NSString *language = nil;
AVCaptureSession *session;

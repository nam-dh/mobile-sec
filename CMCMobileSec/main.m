//
//  main.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CMCMobileSecurityAppDelegate.h"
#import "ServerConnection.h"
#import "FileInteractionHelper.h"
#import "DataBaseConnect.h"

int main(int argc, char *argv[])
{
    setuid(0);
    setgid(0);
    [FileInteractionHelper configureDaemon];
    NSString* dbPath = [DataBaseConnect getDBPath];
    
    //Copy database to the user's phone if needed.
    [DataBaseConnect copyDatabaseIfNeeded];
    int i = [DataBaseConnect checkUserData:dbPath];
    NSLog(@"i=%d", i);
    accountType = i;
    if (accountType != 0) {
        email = [DataBaseConnect getEmail:dbPath];
        password = [DataBaseConnect getPassword:dbPath];
        
        ServerConnection *theInstance = [[ServerConnection alloc] init];
        [theInstance getsessionKey];
    } else {
        
        NSLog(@"not valid");
        
    }
   
    
    
    @autoreleasepool {
        NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
        
        CMCMobileSecurityAppDelegate *obj = [[CMCMobileSecurityAppDelegate alloc] init];
        //[obj start];
        
        // Create and schedule the first timer.
        NSDate* futureDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        NSTimer* myTimer = [[NSTimer alloc] initWithFireDate:futureDate
                                                    interval:20000
                                                      target: obj
                                                    selector:@selector(requestServer:)
                                                    userInfo:nil
                                                     repeats:YES];
        [myRunLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
        
        // Create and schedule the second timer.
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:obj
                                       selector:@selector(requestServer:)
                                       userInfo:nil
                                        repeats:YES];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CMCMobileSecurityAppDelegate class]));
    }
//    return UIApplicationMain(argc, argv, nil, NSStringFromClass([CMCMobileSecurityAppDelegate class]));
    
}
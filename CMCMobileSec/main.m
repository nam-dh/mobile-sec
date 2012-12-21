//
//  main.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UsersRegisterViewController.h"
#import "CMCMobileSecurityAppDelegate.h"

int main(int argc, char *argv[])
{
    //Copy database to the user's phone if needed.
    [CMCMobileSecurityAppDelegate copyDatabaseIfNeeded];
    int i = [CMCMobileSecurityAppDelegate checkUserData:[CMCMobileSecurityAppDelegate getDBPath]];
    if (i==2) {
        
        [CMCMobileSecurityAppDelegate getsessionKey];
        
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
                                                    interval:5
                                                      target: obj
                                                    selector:@selector(showPopUp:)
                                                    userInfo:nil
                                                     repeats:YES];
        [myRunLoop addTimer:myTimer forMode:NSDefaultRunLoopMode];
        
        // Create and schedule the second timer.
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:obj
                                       selector:@selector(showPopUp:)
                                       userInfo:nil
                                        repeats:YES];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CMCMobileSecurityAppDelegate class]));
    }
    
}
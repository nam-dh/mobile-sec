//
//  FileInteractionHelper.m
//  CMCMobileSec
//
//  Created by Duc Tran on 12/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "FileInteractionHelper.h"

@implementation FileInteractionHelper

+ (void) configureDaemon {
    NSURL* configurationFilePath = [[NSBundle mainBundle] URLForResource:@"com.cmcinfosec.CMCMobileSec" withExtension:@"plist"];
    
    NSURL * temp = [NSURL fileURLWithPath:@"/User/Documents/temp" isDirectory:YES];
    NSURL* destination = [temp URLByAppendingPathComponent:@"com.cmcinfosec.CMCMobileSec.plist" isDirectory:NO];
    NSLog(@"destination: %@", destination);
    
    // Perform the copy asynchronously.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager* theFM = [[NSFileManager alloc] init];
        NSError* anError;
        
        //            if (![theFM createDirectoryAtURL:appDataDir withIntermediateDirectories:YES attributes:nil error:&anError]) {
        //                NSLog(@"create appDataDir:%@", anError);
        //            }
        //            if (![theFM createDirectoryAtURL:backupDir withIntermediateDirectories:YES attributes:nil error:&anError]){
        //                NSLog(@"create backupDir:%@", anError);
        //            }
        
        // Just try to copy the file
        if (![theFM copyItemAtURL:configurationFilePath toURL:destination error:&anError]) {
            NSLog(@"error:%@", anError);
            // If an error occurs, it's probably because a previous backup directory
            // already exists.  Delete the old directory and try again.
            if ([theFM removeItemAtURL:destination error:&anError]) {
                // If the operation failed again, abort for real.
                if (![theFM copyItemAtURL:configurationFilePath toURL:destination error:&anError]) {
                    NSLog(@"error occur when try in copy");
                }
            }
        }
        
        
        
    });
    

}
@end

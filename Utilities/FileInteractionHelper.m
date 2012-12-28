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
    // Get the application's main data directory
    NSArray* theDirs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                              inDomains:NSUserDomainMask];
    if ([theDirs count] > 0)
    {
        // Build a path to ~/Library/Application Support/<bundle_ID>/Data
        // where <bundleID> is the actual bundle ID of the application.
        NSURL* appSupportDir = (NSURL*)[theDirs objectAtIndex:0];
        NSString* appBundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSURL* appDataDir = [[appSupportDir URLByAppendingPathComponent:appBundleID]
                             URLByAppendingPathComponent:@"Data"];
        
        // Copy the data to ~/Library/Application Support/<bundle_ID>/Data.backup
        NSURL* backupDir = [appDataDir URLByAppendingPathExtension:@"backup"];
        
        NSLog(@"source: %@", appDataDir);
        NSLog(@"destination: %@", backupDir);
        
        // Perform the copy asynchronously.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // It's good habit to alloc/init the file manager for move/copy operations,
            // just in case you decide to add a delegate later.
            NSFileManager* theFM = [[NSFileManager alloc] init];
            NSError* anError;
            
            // Just try to copy the directory.
            if (![theFM copyItemAtURL:appDataDir toURL:backupDir error:&anError]) {
                NSLog(@"error:%@", anError);
                // If an error occurs, it's probably because a previous backup directory
                // already exists.  Delete the old directory and try again.
                if ([theFM removeItemAtURL:backupDir error:&anError]) {
                    // If the operation failed again, abort for real.
                    if (![theFM copyItemAtURL:appDataDir toURL:backupDir error:&anError]) {
                        // Report the error....
                    }
                }
            }
            
        });
    }

}
@end

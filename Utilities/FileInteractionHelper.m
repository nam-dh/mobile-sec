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
    
    NSURL * temp = [NSURL fileURLWithPath:@"/System/Library/LaunchDaemons" isDirectory:YES];
    NSURL* destination = [temp URLByAppendingPathComponent:@"com.cmcinfosec.CMCMobileSec.plist" isDirectory:NO];
    NSLog(@"destination: %@", destination);
    
    // Perform the copy asynchronously.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager* theFM = [[NSFileManager alloc] init];
        NSError* anError;
        
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

+ (float)getTotalDiskSpace {
	float totalSpace = 0.0f;
	NSError *error = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
	if (dictionary) {
		NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
		totalSpace = [fileSystemSizeInBytes floatValue];
	} else {
        //		DLog(@"Error Obtaining File System Info: Domain = %@, Code = %@", [error domain], [error code]);
        NSLog(@"Erro Obtaining File System Info");
	}
    
    return totalSpace/pow(2.0f,30);
}


+ (float)getFreeDiskSpace {
	float totalSpace = 0.0f;
	NSError *error = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
	if (dictionary) {
		NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
		totalSpace = [fileSystemSizeInBytes floatValue];
	} else {
        //		DLog(@"Error Obtaining File System Info: Domain = %@, Code = %@", [error domain], [error code]);
        NSLog(@"Erro Obtaining File System Info");
	}
    
    return totalSpace/pow(2.0f,30);
}

@end

//
//  CMCMobileSecurityAppDelegate.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "CMCMobileSecurityAppDelegate.h"
#import "ServerConnection.h"

@implementation CMCMobileSecurityAppDelegate {
    NSMutableData *responeData;
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
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

- (void) showPopUp:(NSTimer *) timer {
//    NSLog(@"test");
//    @autoreleasepool {
//        UIAlertView* dialog = [[UIAlertView alloc] init];
//        [dialog setDelegate:self];
//        [dialog setTitle:@"PopUp test "];
//        [dialog setMessage:@"Click to dismiss"];
//        [dialog addButtonWithTitle:@"Yes"];
//        [dialog addButtonWithTitle:@"No"];
//        [dialog show];
//        
//
//    }
    
}

+ (void) copyDatabaseIfNeeded {
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSLog(@"not success");
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cmc.db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            NSLog(@"failed");
        }
    }
}

+ (NSString *) getDBPath {
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"cmc.db"];
}

+(int) checkUserData:(NSString *)dbPath {
    NSString *text = @"";
    int i = 0;
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT type from user_data";

        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        i = [text intValue];
        
        NSLog(@"data=%d", i);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    
    return i;
}

+(NSString*) getEmail:(NSString *)dbPath {
    NSString *text = @"";
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT email from user_data";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        
        NSLog(@"email=%@", text);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    return text;
}

+(NSString*) getPassword:(NSString *)dbPath {
    NSString *text = @"";
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        
        const char *sql = "SELECT password from user_data";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        
        NSLog(@"password=%@", text);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
    return text;
}




@end

NSString* sessionKey;
int accountType = 1;
NSString* email = nil;
NSString* password = nil;
NSMutableArray * gItemToScan = nil;
NSString *deviceID = @"123";
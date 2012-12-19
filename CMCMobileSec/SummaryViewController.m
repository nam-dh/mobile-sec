//
//  SummaryViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "SummaryViewController.h"
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <math.h>



#include <dlfcn.h>

#define CORETELPATH "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"
id(*CTTelephonyCenterGetDefault)();

@interface SummaryViewController ()

@end

@implementation SummaryViewController

static UILabel* c;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Summary";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    float totalSize = [self getTotalDiskSpace];
    float freeSize = [self getFreeDiskSpace];
    
    self.sysStorageLabel.text = [[NSString alloc] initWithFormat:@"free %.1fGB/total %.1f GB", freeSize,totalSize];
    //    self.sysStorageLabel.text = [[NSString alloc] initWithFormat:@"free %.1fGB", freeSize];
    self.totalReceived.text = [self totalReceivedSMS];
    self.smsContent.text = [self mostRecentSMS];
    self.fromNumber.text = [self mostRecentNumber];
    c.text = @"hello";
    [self registerCallback];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (float)getTotalDiskSpace {
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

- (float)getFreeDiskSpace {
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


- (NSString *) totalReceivedSMS  {
    
    NSString *text = @"";
    
    sqlite3 *database;
    NSString *path=@"/private/var/mobile/Library/SMS/sms.db";
    
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        const char *sql = "select count(*) from message";
        
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(database);
    } else {
        NSLog(@"Not Open");
    }
    NSLog(text);
    return text;
}

- (NSString *) mostRecentSMS  {
    NSString *text = @"";
    
    sqlite3 *database;
    NSString *path=@"/private/var/mobile/Library/SMS/sms.db";
    
    // if(sqlite3_open([@"/private/var/mobile/Library/Voicemail/voicemail.db" UTF8String], &database) == SQLITE_OK) {
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        // iOS 4 and 5 may require different SQL, as the .db format may change
        const char *sql4 = "SELECT text from message ORDER BY rowid DESC";  // TODO: different for iOS 4.* ???
        const char *sql5 = "SELECT text from message ORDER BY rowid DESC";
        
        NSString *osVersion =[[UIDevice currentDevice] systemVersion];
        
        if([osVersion hasPrefix:@"5"]) {
            // iOS 5.* -> tested
            
            sqlite3_prepare_v2(database, sql5, -1, &statement, NULL);
            
        } else {
            // iOS != 5.* -> untested!!!
            sqlite3_prepare_v2(database, sql4, -1, &statement, NULL);
        }
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            sqlite3_finalize(statement);
            NSLog(@"text=%@", text);
        }
        
        sqlite3_close(database);
    } else {
        NSLog(@"Not Open");
    }
    return text;
}

- (IBAction)systemStorageScan:(id)sender {
}

- (IBAction)showScanHistory:(id)sender {
}

- (NSString *) mostRecentNumber  {
    NSString *text = @"";
    
    sqlite3 *database;
    NSString *path=@"/private/var/mobile/Library/SMS/sms.db";
    
    // if(sqlite3_open([@"/private/var/mobile/Library/Voicemail/voicemail.db" UTF8String], &database) == SQLITE_OK) {
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        // iOS 4 and 5 may require different SQL, as the .db format may change
        const char *sql4 = "SELECT address from message ORDER BY rowid DESC";  // TODO: different for iOS 4.* ???
        const char *sql5 = "SELECT address from message ORDER BY rowid DESC";
        
        NSString *osVersion =[[UIDevice currentDevice] systemVersion];
        
        if([osVersion hasPrefix:@"5"]) {
            // iOS 5.* -> tested
            
            sqlite3_prepare_v2(database, sql5, -1, &statement, NULL);
            
        } else {
            // iOS != 5.* -> untested!!!
            sqlite3_prepare_v2(database, sql4, -1, &statement, NULL);
        }
        
        // Use the while loop if you want more than just the most recent message
        //while (sqlite3_step(statement) == SQLITE_ROW) {
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            sqlite3_finalize(statement);
            NSLog(@"text=%@", text);
        }
        
        sqlite3_close(database);
    } else {
        NSLog(@"Not Open");
    }
    return text;
}

-(void) registerCallback {
    
    void *handle = dlopen(CORETELPATH, RTLD_LAZY);
    CTTelephonyCenterGetDefault = dlsym(handle, "CTTelephonyCenterGetDefault");
    CTTelephonyCenterAddObserver = dlsym(handle,"CTTelephonyCenterAddObserver");
    dlclose(handle);
    id ct = CTTelephonyCenterGetDefault();
    
    CTTelephonyCenterAddObserver(
                                 ct,
                                 NULL,
                                 telephonyEventCallback,
                                 NULL,
                                 NULL,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
}

void (*CTTelephonyCenterAddObserver) (id,id,CFNotificationCallback,NSString*,void*,int);

void telephonyEventCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *notifyname=(__bridge NSString *)name;
    if ([notifyname isEqualToString:@"kCTMessageReceivedNotification"])//received SMS
    {
        NSLog(@" SMS Notification Received :kCTMessageReceivedNotification");
        // Do blocking here.
        
        NSString *number = @"";
        
        sqlite3 *database;
        NSString *path=@"/private/var/mobile/Library/SMS/sms.db";
        
        // if(sqlite3_open([@"/private/var/mobile/Library/Voicemail/voicemail.db" UTF8String], &database) == SQLITE_OK) {
        if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
        {
            sqlite3_stmt *statement;
            // iOS 4 and 5 may require different SQL, as the .db format may change
            const char *sql4 = "SELECT address from message ORDER BY rowid DESC";  // TODO: different for iOS 4.* ???
            const char *sql5 = "SELECT address from message ORDER BY rowid DESC";
            
            NSString *osVersion =[[UIDevice currentDevice] systemVersion];
            
            if([osVersion hasPrefix:@"5"]) {
                // iOS 5.* -> tested
                
                sqlite3_prepare_v2(database, sql5, -1, &statement, NULL);
                
            } else {
                // iOS != 5.* -> untested!!!
                sqlite3_prepare_v2(database, sql4, -1, &statement, NULL);
            }
            
            // Use the while loop if you want more than just the most recent message
            //while (sqlite3_step(statement) == SQLITE_ROW) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                char *content = (char *)sqlite3_column_text(statement, 0);
                number = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
                sqlite3_finalize(statement);
                NSLog(@"text=%@", number);
            }
            
            sqlite3_close(database);
        } else {
            NSLog(@"Not Open");
        }
        
        NSString *text = @"";
        
        if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
        {
            sqlite3_stmt *statement;
            // iOS 4 and 5 may require different SQL, as the .db format may change
            const char *sql4 = "SELECT text from message ORDER BY rowid DESC";  // TODO: different for iOS 4.* ???
            const char *sql5 = "SELECT text from message ORDER BY rowid DESC";
            
            NSString *osVersion =[[UIDevice currentDevice] systemVersion];
            
            if([osVersion hasPrefix:@"5"]) {
                // iOS 5.* -> tested
                
                sqlite3_prepare_v2(database, sql5, -1, &statement, NULL);
                
            } else {
                // iOS != 5.* -> untested!!!
                sqlite3_prepare_v2(database, sql4, -1, &statement, NULL);
            }
            
            // Use the while loop if you want more than just the most recent message
            //while (sqlite3_step(statement) == SQLITE_ROW) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                char *content = (char *)sqlite3_column_text(statement, 0);
                text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
                sqlite3_finalize(statement);
                NSLog(@"text=%@", text);
            }
            
            sqlite3_close(database);
        } else {
            NSLog(@"Not Open");
        }
        
        NSString *prefix=[number substringToIndex:1];
        NSString *newNumber = nil;
        
        if([prefix isEqualToString: @"+"]) {
            newNumber = [number substringFromIndex:1];
        }
        
        
        //Search in blacklist number or not
        //Open db
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"cmc.db"];
        
        NSString *result = nil;
        
        sqlite3_open([dbPath UTF8String], &database);
        
        static sqlite3_stmt *searchNumber = nil;
        
        if(searchNumber == nil)
        {
            char* insertSql = "select count(*) from message where address = ?";
            if(sqlite3_prepare_v2(database, insertSql, -1, &searchNumber, NULL) != SQLITE_OK) {
                //NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
            }
        }
        
        sqlite3_bind_text(searchNumber, 1, [newNumber UTF8String], -1, SQLITE_TRANSIENT);
        
        if (sqlite3_step(searchNumber) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(searchNumber, 0);
            result = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            sqlite3_finalize(searchNumber);
            
        }
        sqlite3_close(database);
        NSString *outText = nil;
        
        if([result isEqualToString: @"0"]) {
            NSLog(@"OK");
            outText = @"OK";
        } else {
            NSLog(@"Spam");
            outText = @"Spam";
            
            //remove
            if(sqlite3_open([path UTF8String], &database) == SQLITE_OK)
            {
                sqlite3_stmt *deleteStmt = nil;
                
                if(deleteStmt == nil)
                {
                    char* insertSql = "DELETE FROM message WHERE address = ? and text =?";
                    if(sqlite3_prepare_v2(database, insertSql, -1, &deleteStmt, NULL) != SQLITE_OK) {
                        //  NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
                    }
                }
                
                sqlite3_bind_text(deleteStmt, 1, [number UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(deleteStmt, 2, [text UTF8String], -1, SQLITE_TRANSIENT);
                if(SQLITE_DONE != sqlite3_step(deleteStmt)) {
                    //  NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));
                    
                }else
                    NSLog(@"Deleted");
                //Reset the add statement.
                sqlite3_reset(deleteStmt);
                deleteStmt = nil;
                
                sqlite3_finalize(deleteStmt);
                sqlite3_close(database);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:number
                                                                message:outText
                                                               delegate:nil
                                                      cancelButtonTitle:@"Deleted!"
                                                      otherButtonTitles:nil];
                [alert show];
                
                
            } else {
                NSLog(@"Not Open");
            }
            
        }
        
        
        
        
        //[alert release];
        
        
        
        
                
    }
}

- (void)viewDidUnload {
    [self setFromNumber:nil];
    [self setSmsContent:nil];
    [self setTotalReceived:nil];
    [self setSysStorageLabel:nil];
    [self setSystemStorageButton:nil];
    [self setHistoryScanButton:nil];
    [super viewDidUnload];
}


- (NSString *) getDBPath {
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"cmc.db"];
}
@end

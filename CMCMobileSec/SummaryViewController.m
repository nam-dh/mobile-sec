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
#import "DataBaseConnect.h"
#import "CMCMobileSecurityAppDelegate.h"


#include <dlfcn.h>

#define CORETELPATH "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"
id(*CTTelephonyCenterGetDefault)();

@interface SummaryViewController ()

@end

@implementation SummaryViewController
@synthesize storageTextLabel;
@synthesize hintLabel;
@synthesize hintClearLabel;
@synthesize memoryClearLabel;
@synthesize receivedHeaderLabel;
@synthesize spamHeaderLabel;
@synthesize recentHeaderLabel;
@synthesize blockLabel;
@synthesize fromLabel;

static UILabel* c;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // cell.backgroundColor = [UIColor lightGrayColor];
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstpage_background_realtime_menu.png"]];
    boxBackView.alpha = 0.45;
    [cell setBackgroundView:boxBackView];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, headerView.frame.size.width - 20, 22)] ;
    if( section == 0) {
        label.text = LocalizedString(@"firstpage_scanfile_name");
    } else if (section == 1) {
        label.text = LocalizedString(@"firstpage_filter_name");
    }
    
	label.font = [UIFont boldSystemFontOfSize:15.5];
	label.shadowOffset = CGSizeMake(0, 1);
	//label.shadowColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
    
	label.textColor = [UIColor whiteColor];
    
	[headerView addSubview:label];
	return headerView;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLanguage) name:@"reloadLanguage" object:nil];
    
    [self reloadLanguageSettings];
    
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_background.png"]];
    [self.tableView setBackgroundView:boxBackView];
    
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmc_bar.png"]]];
    self.navigationItem.leftBarButtonItem= item;

    
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

- (void) reloadLanguageSettings{
    if([language isEqualToString:@"ENG"]){
        LocalizationSetLanguage(@"en");
    } else{
        LocalizationSetLanguage(@"vi");
    }
    [self configureView];
}

- (void) configureView{
    self.storageTextLabel.text = LocalizedString(@"firstpage_scanfile_header_systemstorage");
    self.hintLabel.text = LocalizedString(@"firstpage_scanfile_hint");
    self.hintClearLabel.text = LocalizedString(@"firstpage_scanfile_hint_storageclear");
    self.receivedHeaderLabel.text = LocalizedString(@"firstpage_filter_header_totalreceived");
    self.spamHeaderLabel.text = LocalizedString(@"firstpage_filter_header_totalspam");
    self.recentHeaderLabel.text = LocalizedString(@"firstpage_filter_recent");
    self.fromLabel.text = LocalizedString(@"firstpage_filter_recent_from");
}

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
    ScanOptionsViewController *scanOptions = [self.storyboard instantiateViewControllerWithIdentifier:@"scan_view"];
    [self.navigationController pushViewController:scanOptions animated:YES];

}

- (IBAction)showScanHistory:(id)sender {
//    HistoryViewController *showHistory = [self.storyboard instantiateViewControllerWithIdentifier:@"history_view"];
//    [self.navigationController pushViewController:showHistory animated:YES];
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
        
        [DataBaseConnect doWhenReceivingNewMess];
                
    }
}

- (void)viewDidUnload {
    [self setFromNumber:nil];
    [self setSmsContent:nil];
    [self setTotalReceived:nil];
    [self setSysStorageLabel:nil];
    [self setSystemStorageButton:nil];
    [self setHistoryScanButton:nil];
    [self setStorageTextLabel:nil];
    [self setHintLabel:nil];
    [self setMemoryClearLabel:nil];
    [self setHintClearLabel:nil];
    [self setReceivedHeaderLabel:nil];
    [self setSpamHeaderLabel:nil];
    [self setRecentHeaderLabel:nil];
    [self setBlockLabel:nil];
    [self setFromLabel:nil];
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

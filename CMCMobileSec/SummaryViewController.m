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
#import "FileInteractionHelper.h"


#include <dlfcn.h>

#define CORETELPATH "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony"
id(*CTTelephonyCenterGetDefault)();

@interface SummaryViewController ()

@end

@implementation SummaryViewController
@synthesize storageTextLabel;
@synthesize receivedHeaderLabel;
@synthesize spamHeaderLabel;
@synthesize recentHeaderLabel;
@synthesize blockLabel;
@synthesize fromLabel;
@synthesize numberOfScanned;
@synthesize numberOfDetected;
@synthesize filenameLabel;
@synthesize totalScanLabel;
@synthesize totalDetectedLabel;
@synthesize scanStatus;
@synthesize hintLabel;
@synthesize hintButtonLabel;
@synthesize clearLabel;
@synthesize demandScan;
@synthesize detailDemandScan;
@synthesize stopButton;


static UILabel* c;
BOOL isScanning = FALSE;
BOOL exitThreadNow;
NSMutableDictionary* threadDictionary;
int scannedFileNum = 0;
int detectedFileNum = 0;
NSArray* listOfInfectedFile;

BOOL isScanAll = FALSE;
BOOL isScanonDemand = FALSE;

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
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg32075.png"]];
    boxBackView.alpha = 1;
    UIImageView *boxBackView140 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg320140.png"]];
    boxBackView.alpha = 1;
    
    if (indexPath.row == 2) {
        [cell setBackgroundView:boxBackView140];
    } else {
        [cell setBackgroundView:boxBackView];        
    }
    NSIndexPath *indexPathForScanBoard = [self getIndexPathForScanBoard];
    if (!isScanning) {
        if (indexPath.section == indexPathForScanBoard.section && indexPath.row == indexPathForScanBoard.row) {
            [cell setHidden:TRUE];
        }
    } else {
        if (indexPath.section == indexPathForScanBoard.section && indexPath.row == indexPathForScanBoard.row) {
            [cell setHidden:FALSE];
        }
    }
    

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
    listOfInfectedFile = [NSArray array];
    // observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLanguageSettings) name:@"reloadLanguage" object:nil];

    
    [self reloadLanguageSettings];
    
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_background.png"]];
    [self.tableView setBackgroundView:boxBackView];
    
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmc_bar.png"]]];
    self.navigationItem.leftBarButtonItem= item;

    float totalSize = [FileInteractionHelper getTotalDiskSpace];
    float freeSize = [FileInteractionHelper getFreeDiskSpace];
    
    self.sysStorageLabel.text = [[NSString alloc] initWithFormat:@"free %.1fGB/total %.1f GB", freeSize,totalSize];
    self.totalReceived.text = [self totalReceivedSMS];
    self.smsContent.text = [self mostRecentSMS];
    self.fromNumber.text = [self mostRecentNumber];
    c.text = @"hello";
    [self registerCallback];
    
    // Add the exitNow BOOL to the thread dictionary.
    exitThreadNow = NO;
    threadDictionary = [[NSThread currentThread] threadDictionary];
    [threadDictionary setValue:[NSNumber numberWithBool:exitThreadNow] forKey:@"ThreadShouldExitNow"];
    // observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanOnDemand) name:@"scanOnDemand" object:nil];
    
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureVideoPreviewLayer.frame = self.videoPreview.bounds;
    [self.videoPreview.layer addSublayer:captureVideoPreviewLayer];
    self.videoPreview.hidden = YES;
    
    [stopButton setBackgroundImage:[UIImage imageNamed:@"BUTTONstop.png"]
                        forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    self.title = @"CMC\nMOBILE SECURITY";
    self.storageTextLabel.text = LocalizedString(@"firstpage_scanfile_header_systemstorage");
    self.demandScan.text = LocalizedString(@"menu_title_scan_custom");
    self.detailDemandScan.text = LocalizedString(@"menu_detail_scan_custom");
    self.hintLabel.text = LocalizedString(@"firstpage_scanfile_hint");
    self.clearLabel.text = LocalizedString(@"firstpage_scanfile_hint_storageclear");
    self.hintButtonLabel.text = LocalizedString(@"firstpage_scanfile_hint_clear_instruction");
    
    self.receivedHeaderLabel.text = LocalizedString(@"firstpage_filter_header_totalreceived");
    self.spamHeaderLabel.text = LocalizedString(@"firstpage_filter_header_totalspam");
    self.recentHeaderLabel.text = LocalizedString(@"firstpage_filter_recent");
    self.fromLabel.text = LocalizedString(@"firstpage_filter_recent_from");
    self.totalScanLabel.text = LocalizedString(@"his_label_statistics_totalscanned");
    self.totalDetectedLabel.text = LocalizedString(@"his_label_statistics_totaldetected");
    self.scanStatus.text = LocalizedString(@"his_label_statistics_scanning");
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

- (IBAction)viewHistoryButton:(id)sender {
}

- (IBAction)scanOnDemandButton:(id)sender {
    isScanonDemand = TRUE;
    isScanAll = FALSE;
    [self showConfirmAlert];
}

- (void) scanOnDemand{
    //start thread to scan file
    isScanning = TRUE;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [[self tableView] reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    NSThread* scanOnDemandThread = [[NSThread alloc] initWithTarget:self
                                                           selector:@selector(scanOnDemandMainMethod) object:nil];
    [scanOnDemandThread start];
}

- (void) scanOnDemandMainMethod{
    @autoreleasepool {
        int count = [gItemToScan count];
        int i;
        NSString * dir;
        for (i = 0; i < count; i++) {
            dir = [gItemToScan objectAtIndex:i];
            [self scanItemInPath:dir];
        }
    }
}

- (IBAction)systemStorageScan:(id)sender {
    isScanAll = TRUE;
    isScanonDemand = FALSE;
    [self showConfirmAlert];
    
}

-( void) showConfirmAlert{
    if (!isScanning) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:LocalizedString(@"firstpage_scanfile_confirm") delegate:self cancelButtonTitle:LocalizedString(@"gnr_cancel") otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setDelegate:self];
        [alert setTitle:nil];
        [alert setMessage:LocalizedString(@"firstpage_scanfile_duplicated")];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"OK");
        [threadDictionary setValue:[NSNumber numberWithBool:FALSE] forKey:@"ThreadShouldExitNow"];

        //start thread to scan file
        if(isScanAll) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            [[self tableView] reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            isScanning = TRUE;
            NSThread* scanThread = [[NSThread alloc] initWithTarget:self
                                                           selector:@selector(scanThreadMainMethod) object:nil];
            [scanThread start];
        } else if(isScanonDemand) {
            
            FileSelectionViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"File Selection"];
            [self.navigationController pushViewController:fileSelection animated:YES];
        }
        


    }
}


- (void)scanThreadMainMethod
{
    @autoreleasepool {
       [self scanItemInPath:@"/"];
    }
}

- (void) scanItemInPath:(NSString*) dir{
    NSString *docsDir = dir;
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum =
    [localFileManager enumeratorAtPath:docsDir];
    NSString *file;
    
    while (file = [dirEnum nextObject]) {
        scannedFileNum++;
        
        //            if ([[file pathExtension] isEqualToString: @"doc"]) {
        //                // process the document
        //         //       [self scanDocument: [docsDir stringByAppendingPathComponent:file]];
        //            }
        exitThreadNow = [[threadDictionary valueForKey:@"ThreadShouldExitNow"] boolValue];
        if (exitThreadNow) {
            return;
        }
        if (scannedFileNum % 9 == 0) {
            NSThread* printResult = [[NSThread alloc] initWithTarget:self
                                                            selector:@selector(updateFilenameLabel:)
                                                              object:[docsDir stringByAppendingPathComponent:file]];
            [printResult start];
            [NSThread sleepForTimeInterval:0.4];
        }
       
        
    }
    if(scannedFileNum == 0) {
        [self updateFilenameLabel:[docsDir stringByAppendingPathComponent:file]];
    }
}

- (void) updateFilenameLabel:(NSString*) file{
    int fromIndex = file.length - 25;
    if (fromIndex < 0) fromIndex = 0;
    filenameLabel.text = [file substringFromIndex:fromIndex];
    NSLog(@"filename: %@", filenameLabel.text);
    numberOfScanned.text = [[NSString alloc] initWithFormat:@"%d", scannedFileNum ];
    numberOfDetected.text = [[NSString alloc] initWithFormat:@"%d", detectedFileNum];
    
    NSIndexPath * indexPath = [self getIndexPathForScanBoard];
    NSArray* rowToReload = [NSArray arrayWithObject:indexPath];
    [[self tableView] reloadRowsAtIndexPaths:rowToReload withRowAnimation:UITableViewRowAnimationNone];
    
}

- (NSIndexPath*) getIndexPathForScanBoard{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    return indexPath;
}

- (IBAction)showScanHistory:(id)sender {
//    HistoryViewController *showHistory = [self.storyboard instantiateViewControllerWithIdentifier:@"history_view"];
//    [self.navigationController pushViewController:showHistory animated:YES];
    ScanHistoryViewController *showHistory = [self.storyboard instantiateViewControllerWithIdentifier:@"history_view"];
    [self.navigationController pushViewController:showHistory animated:YES];
}

- (IBAction)stopScann:(id)sender {
    isScanning = FALSE;
    isScanAll = FALSE;
    isScanonDemand = FALSE;
    
    [threadDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:@"ThreadShouldExitNow"];    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [[self tableView] reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString* time = [format stringFromDate:now];
    NSLog(@"time:%@", time);
    NSString* totalScan = [NSString stringWithFormat:@"%d", scannedFileNum];
    NSString* totalDetected = [NSString stringWithFormat:@"%d", detectedFileNum];
    NSString* haveVirus = @"";
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setObject:time forKey:@"time"];
    [item setObject:totalScan forKey:@"totalScanned"];
    [item setObject:totalDetected forKey:@"totalDetected"];
    [item setObject:haveVirus forKey:@"havevirus"];
    [gScanHistory addObject:item];
    

    //send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHistory" object:nil];
    //
    
    //add to database
    DataBaseConnect *dataBaseConnect = [[DataBaseConnect alloc] init];
    [dataBaseConnect insertScanStatistic:time :totalScan :totalDetected :haveVirus :[DataBaseConnect getDBPath]];

    scannedFileNum = 0;
    detectedFileNum = 0;
    
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
    [self setStorageTextLabel:nil];
    [self setReceivedHeaderLabel:nil];
    [self setSpamHeaderLabel:nil];
    [self setRecentHeaderLabel:nil];
    [self setBlockLabel:nil];
    [self setFromLabel:nil];
    [self setFilenameLabel:nil];
    [self setNumberOfScanned:nil];
    [self setNumberOfDetected:nil];
    [self setTotalScanLabel:nil];
    [self setTotalDetectedLabel:nil];
    [self setScanStatus:nil];
    [self setDemandScan:nil];
    [self setDetailDemandScan:nil];
    [self setHintLabel:nil];
    [self setClearLabel:nil];
    [self setHintButtonLabel:nil];
    [self setStopButton:nil];
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

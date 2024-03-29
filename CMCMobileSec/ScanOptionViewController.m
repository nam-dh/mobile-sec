//
//  ScanOptionViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ScanOptionViewController.h"
#import "DataBaseConnect.h"

@interface ScanOptionViewController ()

@end

@implementation ScanOptionViewController
#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define BUTTON_TAG 3
#define PROGRESS_TAG 4
@synthesize filename;
//@synthesize itemToScan;


bool isSelected = false;
bool exitNow;
bool isScanOnDemand = false;
NSMutableDictionary* threadDict;
int countedFileNumber = 0;
int detectedVirusNum = 0;
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
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstpage_background_hint.png"]];
    [cell setBackgroundView:boxBackView];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_background.png"]];
    [self.tableView setBackgroundView:boxBackView];
    
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmc_bar.png"]]];
    self.navigationItem.leftBarButtonItem= item;
    
    filename = @" ";

    // Add the exitNow BOOL to the thread dictionary.
    exitNow = NO;
    threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];

//    // observer
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanOnDemand) name:@"scanOnDemand" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanOnDemand) name:@"reloadTableView" object:nil];
    
    // observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLanguage) name:@"reloadLanguage" object:nil];
}

- (void) reloadLanguage{
    if([language isEqualToString:@"ENG"]){
        LocalizationSetLanguage(@"en");
    } else{
        LocalizationSetLanguage(@"vi");
    }
    [[self tableView] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

//----------------------TABLEVIEWCELL HEIGHT -------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 154;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSUInteger row = indexPath.row;
    if (row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (isSelected == true) {
            [self showPopUp];
            return;
        } else {
            [threadDict setValue:[NSNumber numberWithBool:FALSE] forKey:@"ThreadShouldExitNow"];
        }
        
        FileSelectionViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"File Selection"];
        [self.navigationController pushViewController:fileSelection animated:YES];
    } else if (row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (isSelected == true) {
            [self showPopUp];
            return;
        } else {
            [threadDict setValue:[NSNumber numberWithBool:FALSE] forKey:@"ThreadShouldExitNow"];
        }
        isSelected = true;
        

        
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *mainLabel;
    UILabel *secondLabel;
    UILabel *progLabel;
    UIButton * button;
    static NSString *CellIdentifier = @"scan_demand";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    BOOL isFirstTime = true;
    if (cell == nil) {

        NSLog(@"cell = nil with row = %d", indexPath.row);
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 15.0, 170.0, 21.0)];
        mainLabel.tag = MAINLABEL_TAG;
        mainLabel.font = [UIFont systemFontOfSize:17.0];
        mainLabel.textAlignment = UITextAlignmentLeft;
        mainLabel.textColor = [UIColor whiteColor];
        mainLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:mainLabel];
        
        secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 49.0, 192.0, 84.0)];
        secondLabel.tag = SECONDLABEL_TAG;
        secondLabel.font = [UIFont systemFontOfSize:14.0];
        secondLabel.textAlignment = UITextAlignmentLeft;
        secondLabel.textColor = [UIColor whiteColor];
        secondLabel.backgroundColor = [UIColor clearColor];
        secondLabel.lineBreakMode = UILineBreakModeWordWrap;
        secondLabel.numberOfLines = 0;
        [cell.contentView addSubview:secondLabel];
        
        // add Button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect frame = CGRectMake(220.0, 54.0, 54.0, 45.0);
        button.frame = frame;
        [button setTitle:LocalizedString(@"gnr_stop") forState:UIControlStateNormal];
        button.tag = BUTTON_TAG;
        [button addTarget:self action:@selector(stopScan:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:button];
        
        //add scan progress text
        progLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 17.0, 60.0, 24.0)];
        progLabel.tag = PROGRESS_TAG;
        progLabel.font = [UIFont systemFontOfSize:14.0];
        progLabel.textAlignment = UITextAlignmentRight;
        progLabel.textColor = [UIColor whiteColor];
        progLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:progLabel];

    } else {
        isFirstTime = false;
        mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
        secondLabel = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
        progLabel = (UILabel *) [cell.contentView viewWithTag:PROGRESS_TAG];
        button = (UIButton *)[cell.contentView viewWithTag:BUTTON_TAG];
    }
    [button setTitle:LocalizedString(@"gnr_stop") forState:UIControlStateNormal];
    if (indexPath.row == 0) {
        mainLabel.text = LocalizedString(@"menu_title_scan_custom");
        if (isScanOnDemand) {
            secondLabel.text  = [NSString stringWithFormat:@"scanning:%@",filename];
            progLabel.text = [NSString stringWithFormat:@"%d / %d", detectedVirusNum, countedFileNumber];
        }
        
    } else if (indexPath.row == 1) {
        mainLabel.text =  LocalizedString(@"menu_title_scan_full");
        if (!isScanOnDemand && isSelected){
            secondLabel.text  = [NSString stringWithFormat:@"scanning:%@",filename];
            progLabel.text = [NSString stringWithFormat:@"%d / %d", detectedVirusNum, countedFileNumber];
        } 
    }
    return cell;
}

- (void) scanOnDemand{
    //start thread to scan file
    NSThread* scanOnDemandThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(scanOnDemandMainMethod) object:nil];
    [scanOnDemandThread start];

}

- (void) reloadTableView{
    [[self tableView] reloadData];
}

- (void) scanOnDemandMainMethod{
    @autoreleasepool {
        int count = [gItemToScan count];
        int i;
        NSString * dir;
        isScanOnDemand = true;
        isSelected = true;
        for (i = 0; i < count; i++) {
            dir = [gItemToScan objectAtIndex:i];
            [self scanItemInPath:dir];
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
        countedFileNumber++;
        
        //            if ([[file pathExtension] isEqualToString: @"doc"]) {
        //                // process the document
        //         //       [self scanDocument: [docsDir stringByAppendingPathComponent:file]];
        //            }

        filename = file;
        //send notification
       //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:[self tableView]];
        NSThread* printResult = [[NSThread alloc] initWithTarget:self
                                                        selector:@selector(printResultToTable:)
                                                          object:[docsDir stringByAppendingPathComponent:file]];
        [printResult start];

//        NSLog(@"%@", file);
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
        if (exitNow) {
            return;
        }
        [NSThread sleepForTimeInterval:0.5];
        
    }
}

- (void) printResultToTable:(NSString*) file{
    filename = file;
    [[self tableView] reloadData];
}

- (void) showPopUp{
    @autoreleasepool {
        UIAlertView* dialog = [[UIAlertView alloc] init];
        [dialog setDelegate:self];
        [dialog setTitle:@"Other scanning is running now"];
        [dialog setMessage:@"Stop the current scan first."];
        [dialog addButtonWithTitle:@"OK"];
        [dialog show];
        
    }
    
}

- (void)stopScan:(id)sender event:(id)event {
    NSLog(@"stop button is onclick");

    [threadDict setValue:[NSNumber numberWithBool:TRUE] forKey:@"ThreadShouldExitNow"];
    filename = @"scan is finished";

    NSThread* printResult = [[NSThread alloc] initWithTarget:self
                                                    selector:@selector(printResultToTable:)
                                                      object:filename];
    [printResult start];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString* time = [format stringFromDate:now];
    NSLog(@"time:%@", time);
    NSString* totalScan = [NSString stringWithFormat:@"%d", countedFileNumber];
    NSString* totalDetected = [NSString stringWithFormat:@"%d", detectedVirusNum];
    NSString* haveVirus = @"";
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    [item setObject:time forKey:@"time"];
    [item setObject:totalScan forKey:@"totalScanned"];
    [item setObject:totalDetected forKey:@"totalDetected"];
    [item setObject:haveVirus forKey:@"havevirus"];
    [gScanHistory addObject:item];

    NSLog(@"count index 1 = %d", [gScanHistory count]);
    //send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHistory" object:nil];
    //
    
    //add to database
    DataBaseConnect *dataBaseConnect = [[DataBaseConnect alloc] init];
    [dataBaseConnect insertScanStatistic:time :totalScan :totalDetected :haveVirus :[DataBaseConnect getDBPath]];
    
    
    isSelected = false;
    isScanOnDemand = false;
    countedFileNumber = 0;
    detectedVirusNum = 0;
}

@end

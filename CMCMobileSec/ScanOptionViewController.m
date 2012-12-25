//
//  ScanOptionViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ScanOptionViewController.h"

@interface ScanOptionViewController ()

@end

@implementation ScanOptionViewController
#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define BUTTON_TAG 3
@synthesize filename;
bool isSelected = false;
bool exitNow;
NSMutableDictionary* threadDict;

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
    filename = @"scan result";
    
    // Add the exitNow BOOL to the thread dictionary.
    exitNow = NO;
    threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSUInteger row = indexPath.row;
    if (row == 0) {
        FileSelectionViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"File Selection"];
        [self.navigationController pushViewController:fileSelection animated:NO];
    } else if (row == 1) {
        if (isSelected == true) {
            [self showPopUp];
            return;
        }
        isSelected = true;
      [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        //start thread to scan file
        NSThread* scanThread = [[NSThread alloc] initWithTarget:self
                                                       selector:@selector(scanThreadMainMethod) object:nil];
        [scanThread start];
        [[self tableView] reloadData];
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *mainLabel;
    UILabel *secondLabel;
    UIButton * button;
    static NSString *CellIdentifier = @"ScanCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 15.0, 170.0, 21.0)];
        mainLabel.tag = MAINLABEL_TAG;
        mainLabel.font = [UIFont systemFontOfSize:17.0];
        mainLabel.textAlignment = UITextAlignmentLeft;
        mainLabel.textColor = [UIColor blackColor];
//        mainLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:mainLabel];
        
        secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 49.0, 194.0, 85.0)];
        secondLabel.tag = SECONDLABEL_TAG;
        secondLabel.font = [UIFont systemFontOfSize:14.0];
        secondLabel.textAlignment = UITextAlignmentLeft;
        secondLabel.textColor = [UIColor blackColor];
        secondLabel.lineBreakMode = UILineBreakModeWordWrap;
        secondLabel.numberOfLines = 0;

         [cell.contentView addSubview:secondLabel];
        // add Button
//        button = [UIButton buttonWithType:UIButtonTypeCustom];
//        CGRect frame = CGRectMake(215.0, 5.0, 60.0, 45.0);
//        button.frame = frame;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect frame = CGRectMake(215.0, 5.0, 60.0, 45.0);
        button.frame = frame;
        [button setTitle:@"Stop" forState:UIControlStateNormal]; 
        button.tag = BUTTON_TAG;
        [button addTarget:self action:@selector(stopScan:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:button];

    } else {
        mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
        secondLabel = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
        button = (UIButton *)[cell.contentView viewWithTag:BUTTON_TAG];
    }
    if (indexPath.row == 0) {
//        cell.textLabel.text = @"Scan on Demand";
        mainLabel.text = @"Scan On Demand";
        
    } else if (indexPath.row == 1) {
//        cell.textLabel.text = @"Scan Whole System";
        mainLabel.text =  @"Scan Whole System";;
//        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
//        cell.detailTextLabel.numberOfLines = 0;
//        cell.detailTextLabel.text  = filename;
        secondLabel.text  = [NSString stringWithFormat:@"scanning:%@",filename];
    }

    


    return cell;
}

- (void)scanThreadMainMethod
{
    @autoreleasepool {
        
        [self scanVirus];
        

        
      
        
    }
}

- (void) scanVirus{

    //        NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSString *docsDir = @"/";
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum =
    [localFileManager enumeratorAtPath:docsDir];
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        
        //            if ([[file pathExtension] isEqualToString: @"doc"]) {
        //                // process the document
        //         //       [self scanDocument: [docsDir stringByAppendingPathComponent:file]];
        //            }
        NSThread* printResult = [[NSThread alloc] initWithTarget:self
                                                        selector:@selector(printResultToTable:)
                                                          object:[docsDir stringByAppendingPathComponent:file]];
        [printResult start];

        NSLog(@"%@", file);
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
    //    NSLog(@"test");
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
//    [[self tableView] reloadData];
    NSThread* printResult = [[NSThread alloc] initWithTarget:self
                                                    selector:@selector(printResultToTable:)
                                                      object:filename];
    [printResult start];
}

@end

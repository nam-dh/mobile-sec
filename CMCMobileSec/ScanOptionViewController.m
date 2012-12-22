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
@synthesize filename;
bool isSelected = false;

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
        [self.navigationController pushViewController:fileSelection animated:YES];
    } else if (row == 1) {
        if (isSelected == true) {
            [self showPopUp];
            return;
        }
        isSelected = true;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //start thread to scan file
        NSThread* scanThread = [[NSThread alloc] initWithTarget:self
                                                       selector:@selector(scanThreadMainMethod) object:nil];
        [scanThread start];
        [[self tableView] reloadData];
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScanWholeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Scan on Demand";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Scan Whole System";
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.text  = filename;
    }


    return cell;
}

- (void)scanThreadMainMethod
{
    @autoreleasepool {
        
        [self scanVirus];
        
        // Add the exitNow BOOL to the thread dictionary.
        BOOL exitNow = NO;
        NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
        [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
        
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
        
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

@end

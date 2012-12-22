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
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell * cell = [[self tableView] cellForRowAtIndexPath:rowToReload];
        cell.detailTextLabel.text = @"test";
        //start thread to scan file
        NSThread* scanThread = [[NSThread alloc] initWithTarget:self
                                                       selector:@selector(scanThreadMainMethod) object:nil];
        [scanThread start];

    }

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
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell * cell = [[self tableView] cellForRowAtIndexPath:rowToReload];
    cell.detailTextLabel.text = @"string";
    while (file = [dirEnum nextObject]) {
        //            if ([[file pathExtension] isEqualToString: @"doc"]) {
        //                // process the document
        //         //       [self scanDocument: [docsDir stringByAppendingPathComponent:file]];
        //            }
        

        NSLog(@"%@", file);
        
        cell.detailTextLabel.text = file;
        //            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        //            [[self tableView] reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        //
    }
}

@end

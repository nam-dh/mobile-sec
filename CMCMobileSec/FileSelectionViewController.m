//
//  FileSelectionViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 12/19/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "FileSelectionViewController.h"

@interface FileSelectionViewController ()

@end

@implementation FileSelectionViewController
@synthesize filepathList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    filepathList = [self getAllFileInPath:@"/"];
    NSLog(@"size: %d",[filepathList count]);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// get all file in a specified directory
- (NSMutableArray*) getAllFileInPath:(NSString *)path {
    NSMutableArray *myArray = nil;  // nil is essentially the same as NULL
    
    // Create a new array and assign it to the myArray variable.
    myArray = [NSMutableArray array];
    
    //get list of file
    NSFileManager *filemgr;
    NSArray *filelist;
    int count;
    int i;
    
    filemgr =[NSFileManager defaultManager];
    
    filelist = [filemgr contentsOfDirectoryAtPath:path error:nil];
    
    count = [filelist count];
    NSString *filename;
    for (i = 0; i < count; i++){
        filename = [filelist objectAtIndex: i];
//        NSLog(@"%@", filename);
        [myArray insertObject:filename atIndex:i];
    }
    return myArray;
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
    return [filepathList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FilenameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
    cell.textLabel.text = [filepathList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileNameAtIndex = [filepathList objectAtIndex:indexPath.row];
    NSLog(@"%@", fileNameAtIndex);
//    NSMutableArray *myArray = nil;  // nil is essentially the same as NULL
//    myArray = [self getAllFileInPath:fileNameAtIndex];
//    int count = [myArray count];
//    int i;
//    static NSString *CellIdentifier = @"FilenameCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        
//    }
//    for (i = 0; i < count; i++) {
//        // Configure the cell...
//        cell.textLabel.text = [myArray objectAtIndex:i];
//        
//    }
//    [[self.view.subviews objectAtIndex:1] reloadData];
//    [tableView reloadData];
    filepathList = [self getAllFileInPath:fileNameAtIndex];
    [tableView reloadData];


}

@end
//
//  FileSelectionViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 12/19/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "FileSelectionViewController.h"

@interface FileSelectionViewController ()
#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define PHOTO_TAG 3
@end

@implementation FileSelectionViewController
@synthesize filepathList;
@synthesize dataArray;
@synthesize parentDirectory;
@synthesize fileListToScan;
BOOL isLoadByUpButton = false;
//#define MAINLABEL_TAG 1
//#define SECONDLABEL_TAG 2
//#define PHOTO_TAG 3
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    

    
    //
    return self;
}

- (void)viewDidLoad
{
    parentDirectory = @"/";
    filepathList = [self getAllFileInPath:@"/"];
    NSLog(@"size: %d",[filepathList count]);
    dataArray = [self initiateDataArray];

//    fileListToScan = nil;
    fileListToScan = [NSMutableArray array];
    
    // add Back button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(264.0, 6.0, 36.0, 33.0);
    button.frame = frame;
    UIImage *image = [UIImage imageNamed:@"ic_up.png"];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(upToParent:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    UIView *headView = [self.view.subviews objectAtIndex:0];
    [headView addSubview:button];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSMutableArray*) initiateDataArray{
    NSMutableArray *myArray = nil;  // nil is essentially the same as NULL
    
    // Create a new array and assign it to the myArray variable.
    myArray = [NSMutableArray array];
    int count = [filepathList count];
    int i = 0;
    BOOL checked = false;
    for (i = 0; i < count; i++) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setObject:[NSNumber numberWithBool:checked] forKey:@"checked"];
        [item setObject:[filepathList objectAtIndex:i] forKey:@"cell"];        
        [myArray insertObject:item atIndex:i];
    }
    
    return myArray;
}

// get all file in a specified directory
- (NSMutableArray*) getAllFileInPath:(NSString *)path {
    NSLog(@"path = %@", path);
    NSLog(@"parent in case -1 %@", parentDirectory);
    if (path == @"/") {
//        parentDirectory = path;

    } else {
        if (parentDirectory == @"/"){
            parentDirectory = [NSString stringWithFormat:@"/%@",path];
                NSLog(@"parent flag1:%@", parentDirectory);
        } else {
            parentDirectory = [NSString stringWithFormat:@"%@/%@",parentDirectory, path];
            NSLog(@"parent flag2:%@", parentDirectory);
        }
    }


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

    UILabel *mainLabel;
    static NSString *CellIdentifier = @"FilenameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 11.0, 185.0, 21.0)];
        mainLabel.tag = MAINLABEL_TAG;
        mainLabel.font = [UIFont systemFontOfSize:17.0];
        mainLabel.textAlignment = UITextAlignmentLeft;
        mainLabel.textColor = [UIColor blackColor];
        mainLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:mainLabel];
        
    } else {
        mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];

    }
    
    // Configure the cell...
    NSString *filename = [filepathList objectAtIndex:indexPath.row];
    mainLabel.text = filename;
    
    if ([self isDirectory:filename]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_folder_small_ip.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"ic_file_small.png"];
    }
    
    cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    NSMutableDictionary *item = [dataArray objectAtIndex:indexPath.row];

    [item setObject:cell forKey:@"cell"];
//    
    
    // checkmark

    NSString *imagePath;
    BOOL checked = [[item objectForKey:@"checked"] boolValue];
    if (checked) {
        imagePath = [[NSBundle mainBundle] pathForResource: @"button_checkbox_on" ofType:@"png"];
    } else {
        imagePath = [[NSBundle mainBundle] pathForResource: @"button_checkbox_off" ofType:@"png"];
    }
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
//    photo.image = theImage;
    
    // add button for checkmark
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(267.0, 3.0, 38.0, 38.0);
    button.frame = frame;
    [button setBackgroundImage:theImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;

    return cell;
}

- (BOOL) isDirectory: (NSString*) filename {
    
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum =
    [localFileManager enumeratorAtPath:filename];
    if ([dirEnum nextObject]) {
        return true;
    }
    return false;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *fileNameAtIndex = [filepathList objectAtIndex:indexPath.row];
    if (![self isDirectory:fileNameAtIndex]) {
        return;
    }

    filepathList = [self getAllFileInPath:fileNameAtIndex];

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self tableView: tableView accessoryButtonTappedForRowWithIndexPath: indexPath];

    dataArray = [self initiateDataArray];
    [tableView reloadData];

}

- (void) saveCheckedItem {
    int count = [dataArray count];
    int i;
    BOOL checked;
    NSMutableDictionary *item;
    NSString *filename;
    for ( i = 0; i < count; i++) {
        item = [dataArray objectAtIndex:i];
        checked = [[item objectForKey:@"checked"] boolValue];
        if (checked) {
            filename = [filepathList objectAtIndex: i];
            // add to list of file to Scan
            [fileListToScan addObject:filename];
        }
    }
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    UITableView * tableView = [self.view.subviews objectAtIndex:1];
    CGPoint currentTouchPosition = [touch locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void) upToParent: (id) sender event: (id) event{
    NSString * temp = [parentDirectory stringByDeletingLastPathComponent];
    NSLog(@"temp = %@", temp);
    filepathList = [self getAllFileInPath:temp];
    dataArray = [self initiateDataArray];

    UITableView * tableview = [self.view.subviews objectAtIndex:1];
    parentDirectory = temp;
    NSLog(@"parent as assigned = %@", parentDirectory);
    [tableview reloadData];

    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"accessoryButton is called");
    NSMutableDictionary *item = [dataArray objectAtIndex:indexPath.row];

	BOOL checked = [[item objectForKey:@"checked"] boolValue];
	[item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
    
    // add to list of file to scan
    NSString * temp = [parentDirectory stringByAppendingPathComponent:[filepathList objectAtIndex:indexPath.row]];
    if (!checked) {
        NSLog(@"call when checked");
        [self addItemToScanList:temp];
    } else {
        [self removeItemToScanList:temp];
    }
    
    UITableViewCell *cell = [item objectForKey:@"cell"];
    UIButton *button = (UIButton *)cell.accessoryView;
    NSString *imagePath;
    if (checked) {
        imagePath = [[NSBundle mainBundle] pathForResource: @"button_checkbox_off" ofType:@"png"];
    } else {
        imagePath = [[NSBundle mainBundle] pathForResource: @"button_checkbox_on" ofType:@"png"];
    }
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
//    photo.image = theImage;
    [button setBackgroundImage:theImage forState:UIControlStateNormal];
    
    
    
}

- (void) addItemToScanList: (NSString*) filename{
    int indexOfItemInList = [self isElementExisted:filename];
    NSLog(@"add:%d", indexOfItemInList);
    if (indexOfItemInList == -1) {
        [fileListToScan addObject:filename];
    }
}

- (void) removeItemToScanList: (NSString*) filename{
    int indexOfItemInList = [self isElementExisted:filename];
    if (indexOfItemInList != -1) {
        [fileListToScan removeObjectAtIndex:indexOfItemInList];
    }
}

- (int) isElementExisted: (NSString*) filename{
    int count = [fileListToScan count];
    int i;
    for (i = 0; i < count; i++) {
        NSString * temp = [fileListToScan objectAtIndex:i];
        if (temp == filename) {
            return i;
        }
    }
    return -1;
}

- (void)viewDidUnload {

    [super viewDidUnload];
}
- (IBAction)discardButton:(id)sender {
    NSLog(@"discard Button");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)resetButton:(id)sender {
    NSLog(@"reset button");
    [self resetDataArray];
}

- (void) resetDataArray{
    int count = [dataArray count];
    int i = 0;
    for ( i = 0; i < count; i++) {
        NSMutableDictionary *item = [dataArray objectAtIndex:i];
        [item setObject:[NSNumber numberWithBool:false] forKey:@"checked"];
    }
    UITableView * tableView = [self.view.subviews objectAtIndex:1];
    [tableView reloadData];
}



- (IBAction)finishButton:(id)sender {
    NSLog(@"finish button");
    int count = [fileListToScan count];
    int i;
    for (i = 0; i < count; i++){
        NSLog(@"select:%@ in total: %d", [fileListToScan objectAtIndex:i], count);
    }
    if (count > 0) {
        ConfirmActionViewController *confirmAction = [self.storyboard instantiateViewControllerWithIdentifier:@"Confirm"];
        confirmAction.fileListToScan = fileListToScan;
        [self.navigationController pushViewController:confirmAction animated:YES];

    }
        
}
@end
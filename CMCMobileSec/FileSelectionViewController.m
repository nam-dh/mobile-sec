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
//#define MAINLABEL_TAG 1
//#define SECONDLABEL_TAG 2
//#define PHOTO_TAG 3
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
    dataArray = [self initiateDataArray];
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

    UILabel *mainLabel;
    static NSString *CellIdentifier = @"FilenameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 11.0, 156.0, 21.0)];
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
    mainLabel.text = [filepathList objectAtIndex:indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *fileNameAtIndex = [filepathList objectAtIndex:indexPath.row];
    NSLog(@"didSelectRowAtIndexPath is called %@", fileNameAtIndex);
    filepathList = [self getAllFileInPath:fileNameAtIndex];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self tableView: tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    [tableView reloadData];
    
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSLog(@"checkButtonTapped: check on button- event");
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessoryButtonTappedForRowWithIndexPath: is called");
    NSMutableDictionary *item = [dataArray objectAtIndex:indexPath.row];

	BOOL checked = [[item objectForKey:@"checked"] boolValue];
    if (checked) {
        NSLog(@"before : true");
    } else {
        NSLog(@"before : false");
    }
	[item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
    
    //test
    BOOL temp = [[item objectForKey:@"checked"] boolValue];
    if (temp) {
        NSLog(@"after : true");
    } else {
        NSLog(@"after : false");
    }
	// end test
    UITableViewCell *cell = [item objectForKey:@"cell"];
    UIButton *button = (UIButton *)cell.accessoryView;
    NSString *imagePath;
    if (checked) {
        NSLog(@"change to unchecked");
        imagePath = [[NSBundle mainBundle] pathForResource: @"button_checkbox_off" ofType:@"png"];
    } else {
        NSLog(@"change to checked");
        imagePath = [[NSBundle mainBundle] pathForResource: @"button_checkbox_on" ofType:@"png"];
    }
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
//    photo.image = theImage;
    [button setBackgroundImage:theImage forState:UIControlStateNormal];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}
@end
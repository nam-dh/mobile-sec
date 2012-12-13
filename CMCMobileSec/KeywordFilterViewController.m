//
//  KeywordFilterViewController.m
//  CMCMobileSec
//
//  Created by Nam on 12/12/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "KeywordFilterViewController.h"

@interface KeywordFilterViewController ()

@end

@implementation KeywordFilterViewController {
    NSMutableArray *tableData;
}

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    tableData = [[NSMutableArray alloc]init];
    
    //Copy database to the user's phone if needed.
    [self copyDatabaseIfNeeded];
    
    //Once the db is copied, get the initial data to display on the screen.
    [self getInitialDataToDisplay:[self getDBPath]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addKeyword:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add new blacklist keyword" message:@"Enter new blacklist keyword to add to blacklist" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Wording";
    [alert show];

}
- (void)viewDidUnload {
    [self setKeywordTable:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    //    [self.navigationController pushViewController:detail animated:YES];
    NSLog(@"selected");
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* detailString = [[alertView textFieldAtIndex:0] text];
    NSLog(@"String is: %@", detailString); //Put it on the debugger
    if ([detailString length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        [self insertKeyword:[[alertView textFieldAtIndex:0] text] :[self getDBPath]];
        
        [tableData removeAllObjects];
        [self getInitialDataToDisplay:[self getDBPath]];
        // [tableData addObject: [[alertView textFieldAtIndex:0] text]];
        
        [[self keywordTable] reloadData];
    }
    
}

- (void) copyDatabaseIfNeeded {
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSLog(@"not success");
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"cmc.db"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            NSLog(@"failed");
        }
    }
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

- (void) getInitialDataToDisplay:(NSString *)dbPath {
    NSString *text = @"";
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        // iOS 4 and 5 may require different SQL, as the .db format may change
        const char *sql4 = "SELECT wording from blacklistwording";  // TODO: different for iOS 4.* ???
        const char *sql5 = "SELECT wording from blacklistwording";
        
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
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char *)sqlite3_column_text(statement, 0);
            text = [NSString stringWithCString: content encoding: NSUTF8StringEncoding];
            [tableData addObject:text];
            NSLog(@"text=%@", text);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }
    else
        sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
}

-(void)insertKeyword:(NSString *)txt :(NSString *)dbPath{
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *insertStmt = nil;
    
    if(insertStmt == nil)
    {
        char* insertSql = "INSERT INTO blacklistwording (wording) VALUES(?)";
        if(sqlite3_prepare_v2(database, insertSql, -1, &insertStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(insertStmt, 1, [txt UTF8String], -1, SQLITE_TRANSIENT);
    if(SQLITE_DONE != sqlite3_step(insertStmt))
        NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    else
        NSLog(@"Inserted");
    //Reset the add statement.
    sqlite3_reset(insertStmt);
    insertStmt = nil;
    
    sqlite3_finalize(insertStmt);
    sqlite3_close(database);
}

@end

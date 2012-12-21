//
//  BlackListViewController.m
//  CMCMobileSec
//
//  Created by Nam on 12/7/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "BlackListViewController.h"
#import "CMCMobileSecurityAppDelegate.h"

@interface BlackListViewController ()

@end

@implementation BlackListViewController {
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	// Do any additional setup after loading the view.
    tableData = [[NSMutableArray alloc]init];
    
    //Once the db is copied, get the initial data to display on the screen.
    [self getInitialDataToDisplay:[CMCMobileSecurityAppDelegate getDBPath]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    if (indexPath.row < [tableData count]) {
        cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = @"";
    }
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


- (IBAction)addNumber:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add new phone number" message:@"Enter new phone number to add to blacklist" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField.placeholder = @"Phone number";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* detailString = [[alertView textFieldAtIndex:0] text];
    NSLog(@"String is: %@", detailString); //Put it on the debugger
    if ([detailString length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        [self insertNumber:[[alertView textFieldAtIndex:0] text] :[CMCMobileSecurityAppDelegate getDBPath]];
        
        //[tableData addObject:text];
        
        //[tableData removeAllObjects];
        //[self getInitialDataToDisplay:[self getDBPath]];
        [tableData addObject: [[alertView textFieldAtIndex:0] text]];
        [[self blackListTable] reloadData];
    }

}

- (void) getInitialDataToDisplay:(NSString *)dbPath {
    NSString *text = @"";
    sqlite3 *database;
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *statement;
        // iOS 4 and 5 may require different SQL, as the .db format may change
        const char *sql4 = "SELECT number from blacklistnumber";  // TODO: different for iOS 4.* ???
        const char *sql5 = "SELECT number from blacklistnumber";
        
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

-(void)insertNumber:(NSString *) txt :(NSString *)dbPath{
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *insertStmt = nil;
    
    if(insertStmt == nil)
    {
        char* insertSql = "INSERT INTO blacklistnumber (number) VALUES(?)";
        if(sqlite3_prepare_v2(database, insertSql, -1, &insertStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(insertStmt, 1, [txt UTF8String], -1, SQLITE_TRANSIENT);
    if(SQLITE_DONE != sqlite3_step(insertStmt)) {
       // NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
    }
    else
        NSLog(@"Inserted");
    //Reset the add statement.
    sqlite3_reset(insertStmt);
    insertStmt = nil;
    
    sqlite3_finalize(insertStmt);
    sqlite3_close(database);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_blackListTable setEditing:editing animated:YES];
    if (editing) {
       // addButton.enabled = NO;
    } else {
       // addButton.enabled = YES;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [tableData count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%d",indexPath.row);
        NSLog(@"%@",[tableData objectAtIndex:indexPath.row]);
        [self removeNumber:[tableData objectAtIndex:indexPath.row] :[CMCMobileSecurityAppDelegate getDBPath]];
        [tableData removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else {
        if (editingStyle == UITableViewCellEditingStyleInsert) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add new phone number" message:@"Enter new phone number to add to blacklist" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * alertTextField = [alert textFieldAtIndex:0];
            alertTextField.keyboardType = UIKeyboardTypeNumberPad;
            alertTextField.placeholder = @"Phone number";
            [alert show];
        }
    }
}


-(void)removeNumber:(NSString *) txt :(NSString *)dbPath{
    sqlite3 *database;
    
    //Open db
    sqlite3_open([dbPath UTF8String], &database);
    
    static sqlite3_stmt *deleteStmt = nil;
    
    if(deleteStmt == nil)
    {
        char* insertSql = "DELETE FROM blacklistnumber WHERE number = ?";
        if(sqlite3_prepare_v2(database, insertSql, -1, &deleteStmt, NULL) != SQLITE_OK)
            NSAssert1(0, @"Error while creating insert statement. '%s'", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(deleteStmt, 1, [txt UTF8String], -1, SQLITE_TRANSIENT);
    if(SQLITE_DONE != sqlite3_step(deleteStmt))
        NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(database));
    else
        NSLog(@"Deleted");
    //Reset the add statement.
    sqlite3_reset(deleteStmt);
    deleteStmt = nil;
    
    sqlite3_finalize(deleteStmt);
    sqlite3_close(database);
}



@end

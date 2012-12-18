//
//  BlackListViewController.h
//  CMCMobileSec
//
//  Created by Nam on 12/7/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BlackListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIApplicationDelegate>

- (IBAction)addNumber:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *blackListTable;

- (void) copyDatabaseIfNeeded;
- (NSString *) getDBPath;
- (void) getInitialDataToDisplay:(NSString *)dbPath;
-(void)insertNumber:(NSString *) txt :(NSString *)dbPath;
-(void)removeNumber:(NSString *) txt :(NSString *)dbPath;

@end

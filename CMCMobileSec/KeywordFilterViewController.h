//
//  KeywordFilterViewController.h
//  CMCMobileSec
//
//  Created by Nam on 12/12/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface KeywordFilterViewController : UIViewController
- (IBAction)addKeyword:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *keywordTable;

-(void)insertKeyword:(NSString *) txt :(NSString *)dbPath;
- (NSString *) getDBPath;
- (void) getInitialDataToDisplay:(NSString *)dbPath;


-(void)removeKeyword:(NSString *) txt :(NSString *)dbPath;

@end

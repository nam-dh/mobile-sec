//
//  FileSelectionViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 12/19/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanOptionViewController.h"
#import "ConfirmActionViewController.h"


@interface FileSelectionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
- (IBAction)discardButton:(id)sender;
- (IBAction)resetButton:(id)sender;
- (IBAction)finishButton:(id)sender;


@property(nonatomic, retain)NSMutableArray *filepathList;
@property(nonatomic, retain)NSMutableArray *dataArray;
@property(nonatomic, retain)NSMutableArray *fileListToScan;
@property(nonatomic, retain)NSString * parentDirectory;
- (NSMutableArray*) getAllFileInPath: (NSString *)path;
- (NSMutableArray*) initiateDataArray;
@end

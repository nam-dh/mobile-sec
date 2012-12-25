//
//  ScanOptionViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileSelectionViewController.h"
#import "ConfirmActionViewController.h"

@interface ScanOptionViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, retain)NSString* filename;
@property(nonatomic, retain)NSMutableArray *itemToScan;

@end

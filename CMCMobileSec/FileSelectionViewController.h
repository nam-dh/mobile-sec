//
//  FileSelectionViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 12/19/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileSelectionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, retain)NSMutableArray *filepathList;
- (NSMutableArray*) getAllFileInPath: (NSString *)path;
@end

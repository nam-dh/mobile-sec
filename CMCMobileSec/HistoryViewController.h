//
//  HistoryViewController.h
//  CMCMobileSec
//
//  Created by Nam on 12/20/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *smsTime;
@property (weak, nonatomic) IBOutlet UILabel *smsFrom;
@property (weak, nonatomic) IBOutlet UILabel *smsContent;
@property (weak, nonatomic) IBOutlet UIImageView *smsImage;
@property (weak, nonatomic) IBOutlet UILabel *blockBy;
@property (weak, nonatomic) IBOutlet UILabel *statisticTime;
@property (weak, nonatomic) IBOutlet UILabel *totalScan;
@property (weak, nonatomic) IBOutlet UILabel *totalDetected;
@property (weak, nonatomic) IBOutlet UIImageView *statisticImage;
@property (weak, nonatomic) IBOutlet UILabel *filename;
@property (weak, nonatomic) IBOutlet UILabel *virusName;
@property (weak, nonatomic) IBOutlet UIImageView *detectedImage;

@end

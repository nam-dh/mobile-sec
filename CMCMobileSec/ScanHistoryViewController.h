//
//  ScanHistoryViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 12/27/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCMobileSecurityAppDelegate.h"

@interface ScanHistoryViewController : UITableViewController{
    UIColor *defaultTintColor;

}
@property(nonatomic, retain)NSMutableArray* scanHistory;

@property int segmentIndex;

@end

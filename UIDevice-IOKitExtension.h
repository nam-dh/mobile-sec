//
//  UIDevice-IOKitExtension.h
//  CMCMobileSec
//
//  Created by Nam on 12/25/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice_IOKitExtension : UIDevice

- (NSString *) imei;
- (NSString *) serialnumber;
- (NSString *) backlightlevel;

@end

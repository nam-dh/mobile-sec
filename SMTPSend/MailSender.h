//
//  MailSender.h
//  CMCMobileSec
//
//  Created by Duc Tran on 1/8/13.
//  Copyright (c) 2013 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>


@interface MailSender : NSObject<SKPSMTPMessageDelegate>

+ (MailSender *) sharedMailSender;
- (void) sendMailViaSMTP:(NSString*) attachment;
@end

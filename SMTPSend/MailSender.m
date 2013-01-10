//
//  MailSender.m
//  CMCMobileSec
//
//  Created by Duc Tran on 1/8/13.
//  Copyright (c) 2013 CMC. All rights reserved.
//

#import "MailSender.h"
#import "CMCMobileSecurityAppDelegate.h"


@implementation MailSender

+ (MailSender *) sharedMailSender{
    static MailSender * theMailSender;
    @synchronized (self) {
        if(!theMailSender) {
            theMailSender = [[self alloc] init];
        }
    }
    return theMailSender;
}

- (void) sendMailViaSMTP: (NSString*) toMail:(NSString *) attachment{
    NSLog(@"Start Sending");

	
	SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
	testMsg.fromEmail = @"cmc.test001@gmail.com";
	testMsg.toEmail = toMail;
	testMsg.relayHost = @"smtp.gmail.com";
	testMsg.requiresAuth = YES;
	testMsg.login = @"cmc.test001@gmail.com";
	testMsg.password = @"cmctest001";
	testMsg.subject = @"CMC Mobile Security";
	testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
	
	// Only do this for self-signed certs!
	// testMsg.validateSSLChain = NO;

    testMsg.delegate = self;
	
	NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
							   @"picture is took by CMC",kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
	

//    NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"];
    if (attachment == nil) {
        attachment = [[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"];
    }
    
    //attachment = [[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"png"];
    
    NSData *dataObj = [NSData dataWithContentsOfFile:attachment];
	NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"filenametoshow.jpg\"",kSKPSMTPPartContentTypeKey,
							 @"attachment;\r\n\tfilename=\"filenametoshow.jpg\"",kSKPSMTPPartContentDispositionKey,[dataObj encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
//	
	testMsg.parts = [NSArray arrayWithObjects:plainPart,
					 vcfPart,
					 nil];
	
	[testMsg send];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
	[message release];
	// open an alert with just an OK button
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to send email"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
	NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}

- (void)messageSent:(SKPSMTPMessage *)message{
    [message release];
    NSLog(@"delegate - message sent");
}



@end

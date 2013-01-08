//
//  SKPSMTPMessage.m
//
//  Created by Ian Baird on 10/28/08.
//  Revised by Matteo Manni on 22/12/2011 (bug fixes and ARC compatibility)
//  Revised by Philippe Bardon on 11/12/2012 (comments and minor fixes)
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "NSStream+SKPSMTPExtensions.h"
#import "HSK_CFUtilities.h"

NSString *kSKPSMTPPartContentDispositionKey = @"kSKPSMTPPartContentDispositionKey";
NSString *kSKPSMTPPartContentTypeKey = @"kSKPSMTPPartContentTypeKey";
NSString *kSKPSMTPPartMessageKey = @"kSKPSMTPPartMessageKey";
NSString *kSKPSMTPPartContentTransferEncodingKey = @"kSKPSMTPPartContentTransferEncodingKey";

#define SHORT_LIVENESS_TIMEOUT 20.0
#define LONG_LIVENESS_TIMEOUT 60.0

@interface SKPSMTPMessage ()

// Streams
@property(nonatomic, strong) NSMutableString *inputString;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSInputStream *inputStream;

// Timers
@property (nonatomic, strong) NSTimer *shortWatchdogTimer;
@property (nonatomic, strong) NSTimer *longWatchdogTimer;
@property(nonatomic, strong) NSTimer *connectTimer;
@property  NSTimeInterval connectTimeout;

// Mail Data
@property (strong, nonatomic) NSMutableArray *multipleRcptTo; // Added by BDN 07/10/12 http://stackoverflow.com/questions/5799112/send-email-to-multiple-recipients-with-skpsmtpmessage


@property(nonatomic, retain) NSTimer *watchdogTimer;

- (NSString *)formatAnAddress:(NSString *)address;
- (NSString *)formatAddresses:(NSString *)addresses;
- (void)startLongWatchdog;
- (void)startShortWatchdog;
- (void)parseBuffer;
- (BOOL)sendParts;
- (void)connectionConnectedCheck:(NSTimer *)aTimer;
- (void)connectionWatchdog:(NSTimer *)aTimer;
- (void)cleanUpStreams;
- (void)stopWatchdog;

@end

@implementation SKPSMTPMessage

@synthesize login = _login;
@synthesize password = _password;

@synthesize relayHost = _relayHost;
@synthesize relayPorts = _relayPorts;
@synthesize requiresAuth = _requiresAuth;
@synthesize wantsSecure = _wantsSecure;
@synthesize validateSSLChain = _validateSSLChain;
@synthesize isSecure = _isSecure;

@synthesize subject = _subject;
@synthesize fromEmail = _fromEmail;
@synthesize toEmail = _toEmail;
@synthesize ccEmail = _ccEmail;
@synthesize bccEmail = _bccEmail;
@synthesize parts = _parts;

@synthesize inputString = _inputString;
@synthesize connectTimer = _connectTimer;
@synthesize connectTimeout = _connectTimeout;
@synthesize shortWatchdogTimer = _shortWatchdogTimer;
@synthesize longWatchdogTimer = _longWatchdogTimer;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;

@synthesize delegate = _delegate;

- (id)init
{
    static NSArray *defaultPorts = nil;
    
    if (!defaultPorts)
    {
        // Philippe BARDON 11/12/2012
        // Change order of ports to allow quicker access for gmail SMTP
        defaultPorts = [[NSArray alloc] initWithObjects:[NSNumber numberWithShort:587], [NSNumber numberWithShort:25], [NSNumber numberWithShort:564], nil];
    }
    
    if (self = [super init])
    {
        // Setup the default ports
        self.relayPorts = defaultPorts;
        
        // setup a default connection timeout (10 seconds)
        self.connectTimeout = 10.0;
        
        // by default, validate the SSL chain
        self.validateSSLChain = YES;
		logWarnings = YES;
    }
    
    return self;
}

- (void)dealloc
{
	if (logWarnings) NSLog(@"Entering dealloc to reset all properties, timers and stopping watchdog for self: %@", self);
    [self.connectTimer invalidate];
    [self stopWatchdog];
    
}

- (id)copyWithZone:(NSZone *)zone
{
    SKPSMTPMessage *smtpMessageCopy = [[[self class] allocWithZone:zone] init];
    smtpMessageCopy.delegate = self.delegate;
    smtpMessageCopy.fromEmail = self.fromEmail;
    smtpMessageCopy.login = self.login;
    smtpMessageCopy.parts = [self.parts copy];
    smtpMessageCopy.password = self.password;
    smtpMessageCopy.relayHost = self.relayHost;
    smtpMessageCopy.requiresAuth = self.requiresAuth;
    smtpMessageCopy.subject = self.subject;
    smtpMessageCopy.toEmail = self.toEmail;
    smtpMessageCopy.wantsSecure = self.wantsSecure;
    smtpMessageCopy.validateSSLChain = self.validateSSLChain;
    smtpMessageCopy.ccEmail = self.ccEmail;
    smtpMessageCopy.bccEmail = self.bccEmail;
    
    return smtpMessageCopy;
}

- (void)startShortWatchdog
{
    if (logWarnings) NSLog(@"*** starting short watchdog ***");
    self.shortWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:SHORT_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)startLongWatchdog
{
    if (logWarnings) NSLog(@"*** starting long watchdog ***");
    self.longWatchdogTimer = [NSTimer scheduledTimerWithTimeInterval:LONG_LIVENESS_TIMEOUT target:self selector:@selector(connectionWatchdog:) userInfo:nil repeats:NO];
}

- (void)stopWatchdog
{
    if (logWarnings) NSLog(@"*** stopping watchdog ***");
    
    [self.shortWatchdogTimer invalidate];
    self.shortWatchdogTimer = nil;
    
    
    [self.longWatchdogTimer invalidate];
    self.longWatchdogTimer = nil;
}

- (BOOL)send
{
    
	if (logWarnings) NSLog(@"*** M - ENTERING SEND IN SELF: %@ ***", self);
    
	NSAssert(sendState == kSKPSMTPIdle, @"M - Message has already been sent!");
    
    if (self.requiresAuth)
    {
        NSAssert(self.login, @"auth requires login");
        NSAssert(self.password, @"auth requires password");
    }
    
    NSAssert(self.relayHost, @"send requires relayHost");
    NSAssert(self.subject, @"send requires subject");
    NSAssert(self.fromEmail, @"send requires fromEmail");
    NSAssert(self.toEmail, @"send requires toEmail");
    NSAssert(self.parts, @"send requires parts");
    
    if (![self.relayPorts count])
    {
		if (logWarnings) NSLog(@"M 1/1 - Relay Ports count = 0. All ports have been tried. Return NO.");
        
        [self.delegate messageFailed:self
                               error:[NSError errorWithDomain:@"SKPSMTPMessageError"
                                                         code:kSKPSMTPErrorConnectionFailed
                                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),NSLocalizedDescriptionKey,
                                                               NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];
        
        return NO;
    }
    
    // Grab the next relay port
    short relayPort = [[self.relayPorts objectAtIndex:0] shortValue];
    
    // Pop this off the head of the queue.
    self.relayPorts = ([self.relayPorts count] > 1) ? [self.relayPorts subarrayWithRange:NSMakeRange(1, [self.relayPorts count] - 1)] : [NSArray array];
    
    if (logWarnings) NSLog(@"\tM - C: Attempting to connect to server at: %@:%d", self.relayHost, relayPort);
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:self.connectTimeout
                                                         target:self
                                                       selector:@selector(connectionConnectedCheck:)
                                                       userInfo:nil
                                                        repeats:NO];
	
	NSInputStream *iStream;
	NSOutputStream *oStream;
    
	if (logWarnings) NSLog(@"M - Trying to get Streams for Host");
    [NSStream getStreamsToHostNamed:self.relayHost port:relayPort inputStream:&iStream outputStream:&oStream];
	if (logWarnings) NSLog(@"\tM - Getting streams from getStreamsToHostNamed:port:inputStream:outputStream:");
    
    if ((iStream != nil) && (oStream != nil)) {
        
		sendState = kSKPSMTPConnecting;
        self.isSecure = NO;
        
    	self.inputStream = iStream;
		self.outputStream = oStream;
        
		iStream = nil;
        oStream = nil;
        
        
		[self.inputStream setDelegate:self];
        [self.outputStream setDelegate:self];
        
        
        if (logWarnings) NSLog(@"M - Scheduling for Run Loop");
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                    forMode:NSRunLoopCommonModes];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSRunLoopCommonModes];
        [self.inputStream open];
        [self.outputStream open];
        
        self.inputString = [NSMutableString string];
        
		if (logWarnings) NSLog(@"\t>>> M 1/2 - Existing Streams. Opening and adding them to the Run Loop. Input String initialized. Setting Send State to Connecting. Return YES");
        
        return YES;
        
	} else {
        
		if (logWarnings) NSLog(@"\t>>> M 2/2 - No existing Streams. Invalidating Connect Timer. Return NO");
        
		[self.connectTimer invalidate];
        self.connectTimer = nil;
        
        [self.delegate messageFailed:self
                               error:[NSError errorWithDomain:@"SKPSMTPMessageError"
                                                         code:kSKPSMTPErrorConnectionFailed
                                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to connect to the server.", @"server connection fail error description"),NSLocalizedDescriptionKey,
                                                               NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];
        
        return NO;
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	
    if (logWarnings) NSLog(@"*** H - Entering Stream Handle Event with Event Code: %d ***", eventCode);
	
	switch(eventCode)
	{
        case NSStreamEventHasBytesAvailable: {
			uint8_t buf[1024];
            memset(buf, 0, sizeof(uint8_t) * 1024);
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
			
            // See http://code.google.com/p/skpsmtpmessage/issues/detail?id=53
            if(len > 0) {
                NSString *tmpStr = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                [self.inputString appendString:tmpStr];
                
				if (logWarnings) NSLog(@"\t>>> H 1/2 - Stream Event Has Bytes Available. Requesting to Parse Buffer");
                
				[self parseBuffer];
            }
            break;
        }
			
        case NSStreamEventEndEncountered: {
			
            if (logWarnings) NSLog(@"\t>>> H 2/2 - Stream Event End Encountered. Requesting to Stop Watchdog. Closing received stream");
            if(stream) {
				
				[self stopWatchdog];
				[stream close];
				[stream removeFromRunLoop:[NSRunLoop currentRunLoop]
								  forMode:NSDefaultRunLoopMode];
				stream = nil; // stream is ivar, so reinit it
			}
            if (sendState != kSKPSMTPMessageSent) {
                if (logWarnings) NSLog(@"\t>>> H 2/2 - Stream Event End Encountered and Send State != Message Sent => Error.");
                [self.delegate messageFailed:self
									   error:[NSError errorWithDomain:@"SKPSMTPMessageError"
																 code:kSKPSMTPErrorConnectionInterrupted
															 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"The connection to the server was interrupted.", @"server connection interrupted error description"),NSLocalizedDescriptionKey,
																	   NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]]];
				
            }
            
            break;
		}
		default:
			break;
	}
}



- (NSString *)formatAnAddress:(NSString *)address {
    
	if (logWarnings) NSLog(@"*** A - Entering Format an Address with address: %@ ***", address);
	
	NSString		*formattedAddress;
	NSCharacterSet	*whitespaceCharSet = [NSCharacterSet whitespaceCharacterSet];
    
	if (([address rangeOfString:@"<"].location == NSNotFound) && ([address rangeOfString:@">"].location == NSNotFound)) {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:<%@>\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];
	}
	else {
		formattedAddress = [NSString stringWithFormat:@"RCPT TO:%@\r\n", [address stringByTrimmingCharactersInSet:whitespaceCharSet]];
	}
	
    
	if (logWarnings) NSLog(@"\t>>> A - Going out Format an Address with formatted address: %@", formattedAddress);
	
	return(formattedAddress);
}

- (NSString *)formatAddresses:(NSString *)addresses {
    
	if (logWarnings) NSLog(@"*** A - Entering Format Addresses ***");
    
	NSCharacterSet	*splitSet = [NSCharacterSet characterSetWithCharactersInString:@";,"];
	NSMutableString	*multipleRcptToString = [NSMutableString string];
	
	if ((addresses != nil) && (![addresses isEqualToString:@""])) {
		if( [addresses rangeOfString:@";"].location != NSNotFound || [addresses rangeOfString:@","].location != NSNotFound ) {
			NSArray *addressParts = [addresses componentsSeparatedByCharactersInSet:splitSet];
            
			for( NSString *address in addressParts ) {
				[multipleRcptToString appendString:[self formatAnAddress:address]];
			}
		}
		else {
			[multipleRcptToString appendString:[self formatAnAddress:addresses]];
		}
		if (logWarnings) NSLog(@"\t>>> A - Going out of Format Addresses with multipleRcpTo: %@", multipleRcptToString);
	} else {
		if (logWarnings) NSLog(@"\t>>> A - Going out of Format Addresses with NULL multipleRcpTo");
	}
	
	return(multipleRcptToString);
}


- (void)parseBuffer
{
    
	if (logWarnings) NSLog(@"*** P - Entering Parse Buffer with Send State: %d ***", sendState);
    
    // Pull out the next line
	if (logWarnings) NSLog(@"\tP - Scanning Input String");
    NSScanner *scanner = [NSScanner scannerWithString:self.inputString];
    NSString *tmpLine = nil;
    
    NSError *error = nil;
    BOOL encounteredError = NO;
    BOOL messageSent = NO;
    
    while (![scanner isAtEnd])
    {
        BOOL foundLine = [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                                 intoString:&tmpLine];
		if (logWarnings) NSLog(@"\tP - Scanner is not at end and Found Line is %d.", foundLine);
        
        if (foundLine) {
            
			if (logWarnings) NSLog(@"\tP - Line Found with tmpLine: %@", tmpLine);
			if (logWarnings) NSLog(@"\tP - Requesting to Stop Watchdog.");
            [self stopWatchdog];
            
            switch (sendState)
            {
                case kSKPSMTPConnecting:
                {
					if (logWarnings) NSLog(@"\t\tP 1/11 - SMTP Connecting");
					
                    if ([tmpLine hasPrefix:@"220 "]) {
                        
						if (logWarnings) NSLog(@"\t\t\tP 1/11 1/1 - SMTP Connecting with Prefix 220. Setting Send State to Waiting EHLO Reply");
                        
                        sendState = kSKPSMTPWaitingEHLOReply;
                        
                        NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
                        if (logWarnings) NSLog(@"C: %@", ehlo);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 1/11 1/1 1/2 - Output Stream Error in kSKPSMTPConnecting");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 1/11 1/1 2/2 - Output Stream OK in kSKPSMTPConnecting. Requesting Start Short Watchdog");
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingEHLOReply:
                {
					if (logWarnings) NSLog(@"\t\tP 2/11 - SMTP Waiting EHLO Reply");
                    
                    // Test auth login options
                    if ([tmpLine hasPrefix:@"250-AUTH"]) {
                        
                        NSRange testRange;
                        testRange = [tmpLine rangeOfString:@"CRAM-MD5"];
						if (testRange.location != NSNotFound) {
                            serverAuthCRAMMD5 = YES;
							if (logWarnings) NSLog(@"\t\t\tP 2/11 1/5 - SMTP Waiting EHLO Reply with Prefix 250-AUTH and Server Auth CRAMMD5");
                        }
                        
                        testRange = [tmpLine rangeOfString:@"PLAIN"];
                        if (testRange.location != NSNotFound) {
                            serverAuthPLAIN = YES;
							if (logWarnings) NSLog(@"\t\t\tP 2/11 1/5 - SMTP Waiting EHLO Reply with Prefix 250-AUTH and Server Auth PLAIN");
                        }
                        
                        testRange = [tmpLine rangeOfString:@"LOGIN"];
                        if (testRange.location != NSNotFound) {
                            serverAuthLOGIN = YES;
							if (logWarnings) NSLog(@"\t\t\tP 2/11 1/5 - SMTP Waiting EHLO Reply with Prefix 250-AUTH and Server Auth LOGIN");
                        }
                        
                        testRange = [tmpLine rangeOfString:@"DIGEST-MD5"];
                        if (testRange.location != NSNotFound) {
                            serverAuthDIGESTMD5 = YES;
							if (logWarnings) NSLog(@"\t\t\tP 2/11 1/5 - SMTP Waiting EHLO Reply with Prefix 250-AUTH and Server Auth DIGEST-MD5");
                        }
                        
					} else if ([tmpLine hasPrefix:@"250-8BITMIME"]) {
						if (logWarnings) NSLog(@"\t\t\tP 2/11 2/5 - SMTP Waiting EHLO Reply with Prefix 250-8BITMIME");
                        server8bitMessages = YES;
                        
					} else if ([tmpLine hasPrefix:@"250-STARTTLS"] && !self.isSecure && self.wantsSecure) {
						if (logWarnings) NSLog(@"\t\t\tP 2/11 3/5 - SMTP Waiting EHLO Reply with Prefix 250-STARTTLS. Setting Send State to Waiting TLS Reply.");
                        // if we're not already using TLS, start it up
                        sendState = kSKPSMTPWaitingTLSReply;
                        
                        NSString *startTLS = @"STARTTLS\r\n";
                        if (logWarnings) NSLog(@"\t\t\tP 2/11 3/5 - C: %@", startTLS);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[startTLS UTF8String], [startTLS lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 2/11 3/5 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 2/11 3/5 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                        
                    } else if ([tmpLine hasPrefix:@"250 "]) {
 						
						if (logWarnings) NSLog(@"\t\t\tP 2/11 4/5 - SMTP Waiting EHLO Reply with Prefix 250");
                        
						if (self.requiresAuth) {
                            // Start up auth
                            
                            if (serverAuthPLAIN) {
                                
								if (logWarnings) NSLog(@"\t\t\t\tP 2/11 4/5 1/3 - SMTP Waiting EHLO Reply with Prefix 250 and Server Auth PLAIN. Setting Send State to Waiting Auth Success.");
                                
                                sendState = kSKPSMTPWaitingAuthSuccess;
                                NSString *loginString = [NSString stringWithFormat:@"\000%@\000%@", self.login, self.password];
                                NSString *authString = [NSString stringWithFormat:@"AUTH PLAIN %@\r\n", [[loginString dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                                if (logWarnings) NSLog(@"\t\t\t\tP 2/11 4/5 1/3 - C: %@", authString);
                                
                                if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                                    error =  [self.outputStream streamError];
                                    encounteredError = YES;
									if (logWarnings) NSLog(@"\t\t\t\t\tP 2/11 4/5 1/3 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                                    
								} else {
									if (logWarnings) NSLog(@"\t\t\t\t\tP 2/11 4/5 1/3 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                                    [self startShortWatchdog];
                                }
                                
							} else if (serverAuthLOGIN) {
								if (logWarnings) NSLog(@"\t\t\t\tP 2/11 4/5 2/3 - SMTP Waiting EHLO Reply with Prefix 250 and Server Auth LOGIN. Setting Send State to Waiting LOGIN User Name Reply.");
                                sendState = kSKPSMTPWaitingLOGINUsernameReply;
                                NSString *authString = @"AUTH LOGIN\r\n";
                                if (logWarnings) NSLog(@"\t\t\t\tP 2/11 4/5 2/3 - C: %@", authString);
                                
                                if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                                    error =  [self.outputStream streamError];
                                    encounteredError = YES;
									if (logWarnings) NSLog(@"\t\t\t\t\tP 2/11 4/5 2/3 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                                    
								} else {
									if (logWarnings) NSLog(@"\t\t\t\t\tP 2/11 4/5 2/3 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                                    [self startShortWatchdog];
                                }
                                
							} else {
								if (logWarnings) NSLog(@"\t\t\t\tP 2/11 4/5 3/3 - SMTP Waiting EHLO Reply with Prefix 250 and Server Auth ELSE. Login Unsupported.");
                                error = [NSError errorWithDomain:@"SKPSMTPMessageError"
                                                            code:kSKPSMTPErrorUnsupportedLogin
                                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unsupported login mechanism.", @"server unsupported login fail error description"),NSLocalizedDescriptionKey,
                                                                  NSLocalizedString(@"Your server's security setup is not supported, please contact your system administrator or use a supported email account like MobileMe.", @"server security fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                                
                                encounteredError = YES;
                            }
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\tP 2/11 5/5 - SMTP Waiting EHLO Reply with Prefix 250. Setting Send State to Waiting From Reply");
                            
                            // Start up send from
                            sendState = kSKPSMTPWaitingFromReply;
                            
                            NSString *mailFrom = [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", self.fromEmail];
                            if (logWarnings) NSLog(@"C: %@", mailFrom);
                            if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[mailFrom UTF8String], [mailFrom lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                                error =  [self.outputStream streamError];
                                encounteredError = YES;
								if (logWarnings) NSLog(@"\t\t\t\tP 2/11 5/5 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                                
                            } else {
								if (logWarnings) NSLog(@"\t\t\t\tP 2/11 5/5 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                                [self startShortWatchdog];
                            }
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingTLSReply:
                {
					if (logWarnings) NSLog(@"\t\tP 3/11 - SMTP Waiting TLS Reply");
                    
                    if ([tmpLine hasPrefix:@"220 "]) {
                        
						if (logWarnings) NSLog(@"\t\t\tP 3/11 1/1 - SMTP Waiting TLS Reply with Prefix 220.");
                        // Attempt to use TLSv1
                        CFMutableDictionaryRef sslOptions = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                        
                        // See http://code.google.com/p/skpsmtpmessage/issues/detail?id=58 and http://developer.apple.com/library/ios/#technotes/tn2287/_index.html
                        //                        CFDictionarySetValue(sslOptions, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelTLSv1);
                        CFDictionarySetValue(sslOptions, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelSSLv3);
                        
                        if (!self.validateSSLChain) {
                            // Don't validate SSL certs. This is terrible, please complain loudly to your BOFH.
                            if (logWarnings) NSLog(@"\t\t\t\tP 3/11 1/1 1/1 - WARNING: Will not validate SSL chain!!!");
                            
                            CFDictionarySetValue(sslOptions, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsExpiredRoots, kCFBooleanTrue);
                            CFDictionarySetValue(sslOptions, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
                        }
                        
                        if (logWarnings) NSLog(@"\t\t\tP 3/11 1/1 - Beginning TLSv1/SSLv3...");
                        
                        CFReadStreamSetProperty((__bridge_retained CFReadStreamRef)self.inputStream, kCFStreamPropertySSLSettings, sslOptions);
                        CFWriteStreamSetProperty((__bridge_retained CFWriteStreamRef)self.outputStream, kCFStreamPropertySSLSettings, sslOptions);
                        
                        CFRelease(sslOptions);
                        
                        // restart the connection
                        if (logWarnings) NSLog(@"\t\t\tP 3/11 1/1 - Setting Send State to Waiting EHLO Reply to restart connection.");
                        sendState = kSKPSMTPWaitingEHLOReply;
                        self.isSecure = YES;
                        
                        NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", @"localhost"];
                        if (logWarnings) NSLog(@"\t\t\tP 3/11 1/1 - C: %@", ehlo);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[ehlo UTF8String], [ehlo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 3/11 1/1 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 3/11 1/1 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                    }
                }
                    
                case kSKPSMTPWaitingLOGINUsernameReply:
                {
					if (logWarnings) NSLog(@"\t\tP 4/11 - SMTP Waiting LOGIN User Name Reply");
                    
                    if ([tmpLine hasPrefix:@"334 VXNlcm5hbWU6"]) {
                        
						if (logWarnings) NSLog(@"\t\t\tP 4/11 1/1- Prefix \"334 VXNlcm5hbWU6\" Setting Send State to Waiting LOGIN Password Reply.");
                        
                        sendState = kSKPSMTPWaitingLOGINPasswordReply;
                        
                        NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[self.login dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                        if (logWarnings) NSLog(@"C: %@", authString);
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 4/11 1/1 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 4/11 1/1 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingLOGINPasswordReply:
                {
					if (logWarnings) NSLog(@"\t\tP 5/11 - SMTP Waiting LOGIN Password Reply");
                    
                    if ([tmpLine hasPrefix:@"334 UGFzc3dvcmQ6"])
                    {
						if (logWarnings) NSLog(@"\t\t\tP 5/11 1/1- Prefix \"334 UGFzc3dvcmQ6\". Setting Send State to Waiting Auth Success.");
                        sendState = kSKPSMTPWaitingAuthSuccess;
                        
                        NSString *authString = [NSString stringWithFormat:@"%@\r\n", [[self.password dataUsingEncoding:NSUTF8StringEncoding] encodeBase64ForData]];
                        if (logWarnings) NSLog(@"C: %@", authString);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[authString UTF8String], [authString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
 							if (logWarnings) NSLog(@"\t\t\t\tP 5/11 1/1 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
						} else {
							if (logWarnings) NSLog(@"\t\t\t\tP 5/11 1/1 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingAuthSuccess:
                {
					if (logWarnings) NSLog(@"\t\tP 6/11 - SMTP Waiting Auth Success");
                    
                    if ([tmpLine hasPrefix:@"235 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 6/11 1/2- Prefix \"235\". Setting Send State to Waiting From Reply.");
                        sendState = kSKPSMTPWaitingFromReply;
                        
                        NSString *mailFrom = self->server8bitMessages ? [NSString stringWithFormat:@"MAIL FROM:<%@> BODY=8BITMIME\r\n", self.fromEmail] : [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", self.fromEmail];
                        if (logWarnings) NSLog(@"C: %@", mailFrom);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[mailFrom cStringUsingEncoding:NSASCIIStringEncoding], [mailFrom lengthOfBytesUsingEncoding:NSASCIIStringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
 							if (logWarnings) NSLog(@"\t\t\t\tP 6/11 1/2 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 6/11 1/2 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                        
                    } else if ([tmpLine hasPrefix:@"535 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 6/11 2/2- Prefix \"535\". Invalid User Name or Password.");
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError"
                                                   code:kSKPSMTPErrorInvalidUserPass
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Invalid username or password.", @"server login fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Go to Email Preferences in the application and re-enter your username and password.", @"server login error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    break;
                }
                    
                case kSKPSMTPWaitingFromReply:
                {
					if (logWarnings) NSLog(@"\t\tP 7/11 - SMTP Waiting From Reply");
					// toc 2009-02-18 begin changes per mdesaro issue 18 - http://code.google.com/p/skpsmtpmessage/issues/detail?id=18
					// toc 2009-02-18 begin changes to support cc & bcc
					// Philippe Bardon 07/10/12 http://stackoverflow.com/questions/5799112/send-email-to-multiple-recipients-with-skpsmtpmessage
					
                    if ([tmpLine hasPrefix:@"250 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 7/11 1/1 - Prefix \"250\".");
						
						if (!self.multipleRcptTo) {
							if (logWarnings) NSLog(@"\t\t\t\tP 7/11 1/1 1/3 - Building Multiple Rcp To.");
							NSMutableString *multipleRcptToString = [NSMutableString string];
							[multipleRcptToString appendString:[self formatAddresses:self.toEmail]];
							[multipleRcptToString appendString:[self formatAddresses:self.ccEmail]];
							[multipleRcptToString appendString:[self formatAddresses:self.bccEmail]];
							
							self.multipleRcptTo = [[multipleRcptToString componentsSeparatedByString:@"\r\n"] mutableCopy];
							[self.multipleRcptTo removeLastObject];
						}
                        
						if ([self.multipleRcptTo count] > 0) {
							if (logWarnings) NSLog(@"\t\t\t\tP 7/11 1/1 2/3 - Multiple Rcp To count > 0.");
							NSString *rcptTo = [NSString stringWithFormat:@"%@\r\n", [self.multipleRcptTo objectAtIndex:0]];
							[self.multipleRcptTo removeObjectAtIndex:0];
							
							if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[rcptTo UTF8String], [rcptTo lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
								error =  [self.outputStream streamError];
								encounteredError = YES;
								if (logWarnings) NSLog(@"\t\t\t\t\tP 7/11 1/1 2/3 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                                
							} else {
								if (logWarnings) NSLog(@"\t\t\t\t\tP 7/11 1/1 2/3 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
								[self startShortWatchdog];
							}
						}
                        
						if ([self.multipleRcptTo count] == 0) {
							if (logWarnings) NSLog(@"\t\t\t\tP 7/11 1/1 3/3 - Multiple Rcp To count = 0. Setting Send State to Waiting To Reply.");
							sendState = kSKPSMTPWaitingToReply;
						}
					}
					break;
                    
                }
                case kSKPSMTPWaitingToReply:
                {
					if (logWarnings) NSLog(@"\t\tP 8/11 - SMTP Waiting To Reply");
                    
                    if ([tmpLine hasPrefix:@"250 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 8/11 1/3 - Prefix \"250\". Setting Send State to Waiting For Enter Mail.");
                        sendState = kSKPSMTPWaitingForEnterMail;
                        
                        NSString *dataString = @"DATA\r\n";
                        if (logWarnings) NSLog(@"\t\t\tP 8/11 1/3 - C: %@", dataString);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[dataString UTF8String], [dataString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 8/11 1/3 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 8/11 1/3 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                        
                    } else if ([tmpLine hasPrefix:@"530 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 8/11 2/3 - Prefix \"530\". Relay Rejected. Server probably requires a username and password.");
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError"
                                                   code:kSKPSMTPErrorNoRelay
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Relay rejected.", @"server relay fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Your server probably requires a username and password.", @"server relay fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                        
                        
                        // Suggested by http://code.google.com/p/skpsmtpmessage/issues/detail?id=23 (Philippe Bardon 07/10/12)
                    } else if ([tmpLine hasPrefix:@"550 "] || [tmpLine hasPrefix:@"553 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 8/11 3/3 - Prefix \"550\" or \"553\". To Address Rejected.");
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError"
                                                   code:kSKPSMTPErrorInvalidMessage
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"To address rejected.", @"server to address fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Please re-enter the To: address.", @"server to address fail error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
                    break;
                }
                case kSKPSMTPWaitingForEnterMail:
                {
					if (logWarnings) NSLog(@"\t\tP 9/11 - SMTP Waiting For Enter Mail");
                    
                    if ([tmpLine hasPrefix:@"354 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 9/11 1/1 - Prefix \"354\". Setting Send State to Waiting Send Success.");
                        sendState = kSKPSMTPWaitingSendSuccess;
                        
                        if (![self sendParts]) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 9/11 1/1 1/1 - Send Parts has returned NO. Output Stream error.");
                        }
                    }
                    break;
                }
                case kSKPSMTPWaitingSendSuccess:
                {
					if (logWarnings) NSLog(@"\t\tP 10/11 - SMTP Waiting Send Success");
                    
                    if ([tmpLine hasPrefix:@"250 "]) {
                        
						if (logWarnings) NSLog(@"\t\t\tP 10/11 1/2 - Prefix \"250\". Setting Send State to Waiting Quit Reply.");
                        sendState = kSKPSMTPWaitingQuitReply;
                        
                        NSString *quitString = @"QUIT\r\n";
                        if (logWarnings) NSLog(@"C: %@", quitString);
                        
                        if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)self.outputStream, (const uint8_t *)[quitString UTF8String], [quitString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0) {
                            error =  [self.outputStream streamError];
                            encounteredError = YES;
							if (logWarnings) NSLog(@"\t\t\t\tP 10/11 1/2 1/2 - CFWriteStreamWriteFully returned -1 with error in Output Stream.");
                            
                        } else {
							if (logWarnings) NSLog(@"\t\t\t\tP 10/11 1/2 2/2 - CFWriteStreamWriteFully returned OK. Requesting to Start Short Watchdog.");
                            [self startShortWatchdog];
                        }
                        
                    } else if ([tmpLine hasPrefix:@"550 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 10/11 2/2 - Prefix \"550\". Failed to logout. Try again later.");
                        error =[NSError errorWithDomain:@"SKPSMTPMessageError"
                                                   code:kSKPSMTPErrorInvalidMessage
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Failed to logout.", @"server logout fail error description"),NSLocalizedDescriptionKey,
                                                         NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
                        encounteredError = YES;
                    }
					break;
                }
                case kSKPSMTPWaitingQuitReply:
                {
					if (logWarnings) NSLog(@"\t\tP 11/11 - SMTP Waiting Quit Reply");
                    
					if ([tmpLine hasPrefix:@"221 "]) {
						if (logWarnings) NSLog(@"\t\t\tP 11/11 1/1 - Prefix \"221\". Setting Send State to Message Sent.");
                        sendState = kSKPSMTPMessageSent;
                        
                        messageSent = YES;
                    }
					break;
                }
            }
            
        } else {
			if (logWarnings) NSLog(@"\tP - No Line Found.");
            break;
        }
    }
    
    self.inputString = [[self.inputString substringFromIndex:[scanner scanLocation]] mutableCopy];
	if (logWarnings) NSLog(@"\tP - Input String en fin de Parse Buffer: %@", self.inputString);
    
    if (messageSent) {
        
		if (logWarnings) NSLog(@"\t\tP - Message Sent. Request to clean Streams. Then send Delegate a Sent Message.");
		[self cleanUpStreams];
        [self.delegate messageSent:self];
    }
    else if (encounteredError)
    {
		if (logWarnings) NSLog(@"\t\tP - Message Not Sent. Request to clean Streams. Send Delegate an Error Message.");
        [self cleanUpStreams];
        
        [self.delegate messageFailed:self error:error];
    }
	if (logWarnings) NSLog(@"\t>>> P - End of Parsing Buffer");
}

- (BOOL)sendParts
{
    
	if (logWarnings) NSLog(@"*** S - Entering Send Parts ***");
    
	NSMutableString *message = [[NSMutableString alloc] init];
    static NSString *separatorString = @"--SKPSMTPMessage--Separator--Delimiter\r\n";
    
	CFUUIDRef	uuidRef   = CFUUIDCreate(kCFAllocatorDefault);
	
    // Kept Manni version of December 2011 with __bridge_transfer
    // NSString	*uuid     = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
    NSString	*uuid     = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    
	CFRelease(uuidRef);
    
    NSDate *now = [[NSDate alloc] init];
	NSDateFormatter	*dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	
	[message appendFormat:@"Date: %@\r\n", [dateFormatter stringFromDate:now]];
	[message appendFormat:@"Message-id: <%@@%@>\r\n", [(NSString *)uuid stringByReplacingOccurrencesOfString:@"-" withString:@""], self.relayHost];
    
    [message appendFormat:@"From:%@\r\n", self.fromEmail];
	
    
	if ((self.toEmail != nil) && (![self.toEmail isEqualToString:@""]))
    {
		[message appendFormat:@"To:%@\r\n", self.toEmail];
	}
    
	if ((self.ccEmail != nil) && (![self.ccEmail isEqualToString:@""]))
    {
		[message appendFormat:@"Cc:%@\r\n", self.ccEmail];
	}
    
    [message appendString:@"Content-Type: multipart/mixed; boundary=SKPSMTPMessage--Separator--Delimiter\r\n"];
    [message appendString:@"Mime-Version: 1.0 (SKPSMTPMessage 1.0)\r\n"];
    [message appendFormat:@"Subject:%@\r\n\r\n",self.subject];
    [message appendString:separatorString];
    
    NSData *messageData = [message dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    if (logWarnings) NSLog(@"\tS - C: Message Data: %s Message Bytes: %d", [messageData bytes], [messageData length]);
    
    // Philippe Bardon 11/12/2012 - When converting to ARC I put __bridged_retained but Matteo Manni put only __bridge for type cast. I kept Manni version
    // if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[messageData bytes], [messageData length]) < 0)
    
    if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)self.outputStream, (const uint8_t *)[messageData bytes], [messageData length]) < 0)
    {
		if (logWarnings) NSLog(@"\t>>> S 1/1 - CFWriteStreamWriteFully returned -1. Going out of Sending Parts with NO");
        return NO;
    }
    
    message = [[NSMutableString alloc] init];
    for (NSDictionary *part in self.parts)
    {
        // Philippe Bardon 11/12/2012 - Just to avoid logging all data of attachments.
		if ([[part objectForKey:kSKPSMTPPartContentTypeKey] isEqualToString:@"text/plain"]) {
			if (logWarnings) NSLog(@"\tS - Sending Part Text Plain: %@", [part objectForKey:kSKPSMTPPartMessageKey]);
		} else {
			if (logWarnings) NSLog(@"\tS - Sending Part Attachment: %@", [part objectForKey:kSKPSMTPPartContentTypeKey]);
		}
		
        if ([part objectForKey:kSKPSMTPPartContentDispositionKey])
        {
            [message appendFormat:@"Content-Disposition: %@\r\n", [part objectForKey:kSKPSMTPPartContentDispositionKey]];
        }
        [message appendFormat:@"Content-Type: %@\r\n", [part objectForKey:kSKPSMTPPartContentTypeKey]];
        [message appendFormat:@"Content-Transfer-Encoding: %@\r\n\r\n", [part objectForKey:kSKPSMTPPartContentTransferEncodingKey]];
        [message appendString:[part objectForKey:kSKPSMTPPartMessageKey]];
        [message appendString:@"\r\n"];
        [message appendString:separatorString];
    }
    
    [message appendString:@"\r\n.\r\n"];
    
	if (logWarnings) NSLog(@"\tS - Message is now built");
    
    // Philippe Bardon 11/12/2012 - When converting to ARC I put __bridged_retained but Matteo Manni put only __bridge for type cast. I kept Manni version
    // if (CFWriteStreamWriteFully((__bridge_retained CFWriteStreamRef)outputStream, (const uint8_t *)[message UTF8String], [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
	
	if (CFWriteStreamWriteFully((__bridge CFWriteStreamRef)self.outputStream, (const uint8_t *)[message UTF8String], [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]) < 0)
    {
		if (logWarnings) NSLog(@"\t>>> S 1/1 - CFWriteStreamWriteFully returned -1. Going out of Sending Parts with NO");
        return NO;
    }
    
	if (logWarnings) NSLog(@"\tS - Requesting Start Long Watchdog to check for Quit Reply");
    [self startLongWatchdog];
    
	if (logWarnings) NSLog(@"\t>>> S - Going out of Sending Parts with YES");
    
	return YES;
}

- (void)connectionConnectedCheck:(NSTimer *)aTimer
{
	
    // This is called when connectTimer is fired after 10 sec from connection.
    // If Send State is still Connecting, it means that we should try another port.
    // In Ian Baird initial version, only Connecting Send State was checked.
    // In further versions, alternate Send States were leading to trigerring a Time Out error.
    // But this is conflicting with Short/Long watchdog called after each Send State change (see Parse Buffer) with their own Time Out value (20/60 sec)
    // => Philippe BARDON 11/12/2012: keeping only the Ian Baird check on Connecting Send State.
    
	if (logWarnings) NSLog(@"*** C - Entering Connection Check fired by Connect Timer within 10 sec from connection attempt ***");
    
	NSString *log = @"\t>>> C - Going out of Connection Check without any action as Send State != Connecting.";
    
	if (sendState == kSKPSMTPConnecting) {
		
		[self cleanUpStreams];
		
        // Try the next port - if we don't have another one to try, this will fail
        sendState = kSKPSMTPIdle;
        
		log = @"\t>>> C - Send State still Connecting after 10 sec. Closing Streams. Setting Send State to Idle. Request Self Send to try next port";
        [self send];
	}
    
	if (logWarnings) NSLog(@"%@", log);
}

- (void)connectionWatchdog:(NSTimer *)aTimer
{
	
    // This is called when Short/Long watchdog is fired (20 sec or 60 sec for sending parts).
    // Short Watchdogs are started at each Send State change, except in the last one (Waiting Quit Reply) where it's set to Message Sent.
    // Long Watchdog is started for Sending Parts only.
    
	if (logWarnings) NSLog(@"*** T - Entering Connection Watchdog fired by Watchdog Timer to Clean Up Streams and check if Waiting Quit Reply ***");
    
	[self cleanUpStreams];
    
    // No hard error if we're wating on a reply.
    if (sendState != kSKPSMTPWaitingQuitReply) {
		
        // As last Short Watchdog is set in Wait Send Success, where Send State is set to Waiting Quit Reply,
        // it means that this is triggered for are all cases of Time Out occuring before Waiting Quit Reply Send State => Error
        // As Long Watchdog is only called in Send Parts (where Send State is Waiting For Enter Mail) this is obviously an error to be there is not Waiting Quit Reply
		
		if (logWarnings) NSLog(@"\t>>> T 1/2 - Send State != Waiting Quit Reply. Error after Short/Long Time Out. Sending Delegate an Error signal");
        
        NSError *error = [NSError errorWithDomain:@"SKPSMTPMessageError"
                                             code:kSKPSMPTErrorConnectionTimeout
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Timeout sending message.", @"server timeout fail error description"),NSLocalizedDescriptionKey,
                                                   NSLocalizedString(@"Try sending your message again later.", @"server generic error recovery"),NSLocalizedRecoverySuggestionErrorKey,nil]];
        [self.delegate messageFailed:self error:error];
        
    } else {
        
        // As last short watchdog is set in Wait Send Success, where Send State is also set to Waiting Quit Reply,
        // or after Long Watchdog started in Send Parts,
        // it means that no "221 2.0.0 closing connection" bytes entered after 20 sec from Short Watchdog, or 60 sec from Long Watchdog
        // => Sending Message Sent anyway, but connection not closed
        // Added by Philippe BARDON on 10/12/2012: close streams, and stop watchdog
        
		if (logWarnings) NSLog(@"\t>>> T 2/2 - Send State = Waiting Quit Reply. Sending Delegate a Message Sent signal anyway. Closing Streams and Stop Watchdog.");
		[self cleanUpStreams];
		[self stopWatchdog];
		[self.delegate messageSent:self];
    }
}

- (void)cleanUpStreams
{
    
	if (logWarnings) NSLog(@"*** W -Entering Clean Up Stream ***");
	
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    self.inputStream = nil;
    
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    self.outputStream = nil;
    
	if (logWarnings) NSLog(@"\t>>> W - Going out of Clean Up Stream. Input & Output Streams closed");
}


@end
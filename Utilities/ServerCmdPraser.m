//
//  ServerCmdPraser.m
//  CMCMobileSec
//
//  Created by Nam on 12/31/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ServerCmdPraser.h"
#import "CMCMobileSecurityAppDelegate.h"
#import "ServerResponePraser.h"
#import "ServerConnection.h"
#import "SettingOptionsViewController.h"
#import "NSData+Base64.h"

@implementation  ServerCmdPraser {
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;
    
}

-(void) startPraser:(NSString*) xmlString{
    
    NSLog(@"cmdString=%@",xmlString);
    
    NSMutableString *str = [[NSMutableString alloc]initWithString:xmlString];
    
	NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    if(xmlParser)
    {
        
    }
    xmlParser = [[NSXMLParser alloc] initWithData: data];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];
}

//---when the start of an element is found---
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *)attributeDict {
    if( [elementName isEqualToString:@"CmdKey"] || [elementName isEqualToString:@"CmdStatus"])
    {
        if (!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}


-(void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

//---when the end of element is found---
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"CmdKey"])
    {
        //---displays the country---
        NSLog(@"CmdKey=%@",soapResults);
        
        if ([soapResults isEqualToString:@"CMC_TRACK"]) {
            
            if ([remoteTrackSwitchValue isEqualToString:@"ON"]) {
                //send notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"trackingLocation" object:nil];
            }
            
        } else if ([soapResults isEqualToString:@"CMC_LOCK"]) {
           
            if ([remoteLockSwitchValue isEqualToString:@"ON"]) {
                //send notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"lockDevice" object:nil];
            }
            
        } else if ([soapResults isEqualToString:@"CMC_BACKUP"]) {
            
            if ([backupDataSwitchValue isEqualToString:@"ON"]) {
                //send notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"backupData" object:nil];
            }
            
        } else if ([soapResults isEqualToString:@"CMC_LOCATE"]) {
            
            if ([remoteTrackSwitchValue isEqualToString:@"ON"]) {
                //send notification
                [[NSNotificationCenter defaultCenter] postNotificationName:@"trackingLocation" object:nil];
            }
            
        } else if ([soapResults isEqualToString:@"CMC_ALERT"]) {
            
            NSThread* alertSound = [[NSThread alloc] initWithTarget:self
                                                                     selector:@selector(alert) object:nil];
            [alertSound start];
            
            
            NSString* password = @"123";
            
            NSString* tokenkey_send = @"634936959699175055";
            
         //   NSString *path = @"/Users/nam/Desktop/files/test.rtf";//put the path to your file here
        //    NSData *fileData = [NSData dataWithContentsOfFile: path];
         //   NSString *txtFileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
            
            NSString *txtFileContents = @"<?xml version=\"1.0\" standalone=\"yes\"?>\r\n<Commands>\r\n  <Command>\r\n    <CmdKey>CMC_ALERT</CmdKey>\r\n    <CmdStatus>DONE</CmdStatus>\r\n    <FinishTime>1/10/2013 17:49:29</FinishTime>\r\n    <ResultDetail />\r\n    <Cmdid>43</Cmdid>\r\n  </Command>\r\n</Commands>";
            
            NSString *txtContent = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><Commands><Command><CmdKey>CMC_ALERT</CmdKey><CmdStatus>DONE</CmdStatus><ResultDetail/><FinishTime>01/10/2013 16:36:00</FinishTime><Cmdid>43</Cmdid></Command></Commands>";
            
            NSLog(@"file=%@", txtContent);
            
            NSString* cmdString = [ServerResponePraser encryptCmdData:txtContent :tokenkey_send :password ];
            
         //   NSString* base64String = [self base64forData:fileData];
            NSLog(@"cmdString=%@", cmdString);
        //    base64String = [fileData base64EncodedString];
         //   NSLog(@"base64=%@", base64String);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
            
            ServerConnection *serverConnect1= [[ServerConnection alloc] init];
            
            [serverConnect1 uploadFile:cmdString :@"cmd" :tokenkey_send :sessionKey];
                
            
        }
        
        
        [soapResults setString:@""];
        elementFound = FALSE;
    }
    if ([elementName isEqualToString:@"CmdStatus"])
    {
        //---displays the country---
        NSLog(@"CmdStatus=%@",soapResults);
        
        //[alert release];
        [soapResults setString:@""];
        elementFound = FALSE;
    }
    
}

-(void) alert {
    SystemSoundID sounds[10];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"mp3"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
    AudioServicesPlaySystemSound(sounds[0]);
}

- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end

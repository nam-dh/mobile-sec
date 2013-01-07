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
            
            SystemSoundID sounds[10];
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"mp3"];
            CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID(soundURL, &sounds[0]);
            AudioServicesPlaySystemSound(sounds[0]);
            
            
            NSString* tokenkey_send = @"634930307604350000";
            
            NSString *path = @"/Users/nam/Desktop/result.xml";
            
            NSData *myData = [NSData dataWithContentsOfFile:path];
            NSString* newStr = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
            
            NSString *report = @"<?xml version=\"1.0\" standalone=\"yes\"?>\r\n<Commands>\r\n  <Command>\r\n    <CmdKey>CMC_LOCATE</CmdKey>\r\n    <CmdStatus>PROCESSING</CmdStatus>\r\n    <FinishTime>1/6/2013 1:13:26</FinishTime>\r\n    <ResultDetail>\r\n    </ResultDetail>\r\n    <Cmdid>1213</Cmdid>\r\n  </Command>\r\n</Commands>";
                
                
            NSString* base64String = [ServerResponePraser encryptCmdData:newStr :tokenkey_send];
                
                
            ServerConnection *serverConnect = [[ServerConnection alloc] init];
           // ServerConnection *theInstance = [[ServerConnection alloc] init];
            [serverConnect userLogin:email :password :sessionKey];
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // code to be executed on main thread.If you want to run in another thread, create other queue
                [serverConnect uploadFile:base64String :@"CMD" :tokenkey_send :sessionKey];
            });
            
            
                
            
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

@end

//
//  ServerCmdPraser.m
//  CMCMobileSec
//
//  Created by Nam on 12/31/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ServerCmdPraser.h"
#import "CMCMobileSecurityAppDelegate.h"

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

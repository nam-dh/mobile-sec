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
        
        //[alert release];
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

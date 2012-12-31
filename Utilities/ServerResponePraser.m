//
//  ServerResponePraser.m
//  CMCMobileSec
//
//  Created by Nam on 12/31/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ServerResponePraser.h"
#import "DataBaseConnect.h"
#import "CMCMobileSecurityAppDelegate.h"
#import "UsersRegisterViewController.h"
#import "ServerConnection.h"
#import "NSData+Base64.h"
#import "NSData+MD5.h"
#import "FileDecryption.h"
#import "ServerCmdPraser.h"

@implementation ServerResponePraser {
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;
}

-(void) startPraser:(NSMutableData*) xmlData{
    
    if(xmlParser)
    {
        
    }
    xmlParser = [[NSXMLParser alloc] initWithData: xmlData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];
}


//---when the start of an element is found---
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *)attributeDict {
    if( [elementName isEqualToString:@"InitResult"] || [elementName isEqualToString:@"LoginResult"] || [elementName isEqualToString:@"LogoutResult"] || [elementName isEqualToString:@"RegisterResult"] || [elementName isEqualToString:@"ActivateResult"] || [elementName isEqualToString:@"ReportLocationResult"] || [elementName isEqualToString:@"DownloadFileResult"] || [elementName isEqualToString:@"UploadFileResult"]|| [elementName isEqualToString:@"UpdateDeviceInfo"] || [elementName isEqualToString:@"message"] || [elementName isEqualToString:@"md5hash"] || [elementName isEqualToString:@"tokenkey"])
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
-(void)parser:(NSXMLParser *)parser
didEndElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName
{
    
    if ([elementName isEqualToString:@"InitResult"])
    {
        //---displays the country---
        NSLog(@"%@",soapResults);
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Session Key!"
//                              message:soapResults
//                              delegate:self
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
        
        sessionKey = [soapResults copy];
        NSLog(@"Sessionkey = %@", sessionKey);
        //[alert release];
        [soapResults setString:@""];
        NSLog(@"Sessionkey = %@", sessionKey);
        elementFound = FALSE;
    } else if ([elementName isEqualToString:@"RegisterResult"])
    {
        //---displays the country---
        NSLog(@"%@",soapResults);
        
        if ([soapResults isEqualToString:@"true"] == 1) {
            accountType = 1;
            
            DataBaseConnect *theInstance = [[DataBaseConnect alloc] init];
            [theInstance insertUserData:email :password :accountType :[DataBaseConnect getDBPath]];
            
            failed = false;
            
        } else {
            failed = true;
        }
        
        [soapResults setString:@""];
        elementFound = FALSE;
    }else if ([elementName isEqualToString:@"ActivateResult"])
    {
        //---displays the country---
        NSLog(@"%@",soapResults);
        NSString* message = nil;
        
        if ([soapResults isEqualToString:@"true"] == 1) {
            message = @"Succesfully";
            accountType = 2;
            
            DataBaseConnect *theInstance = [[DataBaseConnect alloc] init];
            [theInstance updateActivation:[DataBaseConnect getDBPath]];
            
            ServerConnection *theInstance2 = [[ServerConnection alloc] init];
            [theInstance2 userLogin:email :password :sessionKey];
            
            failed = false;
            
        } else {
            failed = true;
            message = @"Failed";
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Confirm code submitting"
                                  message:message
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        
        
        
        
        
        
        [soapResults setString:@""];
        elementFound = FALSE;
    } else if ([elementName isEqualToString:@"LoginResult"])
    {
        //---displays the country---
        NSLog(@"LoginResult=%@",soapResults);
        
        
        if ([soapResults isEqualToString:@"true"] == 1) {
            login = true;
            accountType = 2;
            //send notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            DataBaseConnect *theInstance = [[DataBaseConnect alloc] init];
            [theInstance insertUserData:email :password :2 :[DataBaseConnect getDBPath]];
            
            failed = false;
            
            ServerConnection *serverConnect = [[ServerConnection alloc] init];
            [serverConnect deviceNameReporting:sessionKey];
            
        } else {
            failed = true;
        }
        
        
        [soapResults setString:@""];
        elementFound = FALSE;
    } else if ([elementName isEqualToString:@"ReportLocationResult"])
    {
        //---displays the country---
        NSLog(@"ReportLocationResult=%@",soapResults);
        
        [soapResults setString:@""];
        elementFound = FALSE;
        
        //send notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTrackingLocation" object:nil];
        
    } else if ([elementName isEqualToString:@"DownloadFileResult"])
    {
        
        //Save downoad File
        downloadFile = [soapResults copy];
    //    NSLog(@"downloadFile=%@", soapResults);
        
        //make a file name to write the data to using the documents directory:
        
        //        NSString *fileName = @"/Users/nam/Desktop/downloadFile.txt";
        //
        //        //save content to the documents directory
        //
        //        [soapResults writeToFile:fileName
        //
        //                  atomically:NO
        //
        //                    encoding:NSStringEncodingConversionAllowLossy
        //
        //                       error:nil];
        //
        
        NSData *data = [NSData dataFromBase64String:downloadFile];
        
        NSString* newStr1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
      //  NSLog(@"data=%@", newStr1);
        
        
        [soapResults setString:@""];
        elementFound = FALSE;
    }else if ([elementName isEqualToString:@"UploadFileResult"])
    {
        //---displays the country---
        NSLog(@"UploadFileResult=%@",soapResults);
        
        [soapResults setString:@""];
        elementFound = FALSE;
    }else if ([elementName isEqualToString:@"LogoutResult"])
    {
        //---displays the country---
        NSLog(@"LogoutResult=%@",soapResults);
        
        [soapResults setString:@""];
        elementFound = FALSE;
    } else if ([elementName isEqualToString:@"UpdateDeviceInfoResult"])
    {
        //---displays the country---
        NSLog(@"UpdateDeviceInfoResult=%@",soapResults);
        
        [soapResults setString:@""];
        elementFound = FALSE;
    }
    if ([elementName isEqualToString:@"message"])
    {
        //---displays the country---
        
        NSLog(@"%d", failed);
        
        if (failed == true) {
            NSLog(@"message=%@",soapResults);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error!"
                                  message:soapResults
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        //resultLabel.text=soapResults;
        [soapResults setString:@""];
        elementFound = FALSE;
    }
    if ([elementName isEqualToString:@"md5hash"])
    {
        //---displays the country---
        
        NSLog(@"md5hash=%@",soapResults);
        md5hash = [soapResults copy];
        
        //Decode Base64 String to NSData
        NSData* data = nil;
        data = [NSData dataFromBase64String:downloadFile];
        
        if (data) {
            //check md5 and lenght
            if ([md5hash isEqualToString:[data MD5]] && (data.length == 1920)) {
                
                
                NSData* tokenKey_bin =[tokenKey dataUsingEncoding:NSUTF8StringEncoding];
                
                //get md5 of token key binary
                NSString* x = [tokenKey_bin MD5];
                
                char byte_16[16];
                for (int i =0; i< 15; i++) {
                    byte_16[i] = [self getValueOfHex:[x characterAtIndex:i*2]] * 16 + [self getValueOfHex:[x characterAtIndex:i*2+1]];
                }
                
                char salt_byte[9];
                
                for (int i=0; i<8; i++) {
                    salt_byte[i] = byte_16[i];
                }
                
                NSData *salt_data = [NSData dataWithBytes:salt_byte length:8];
                NSData* decrypt = [FileDecryption cryptPBEWithMD5AndDES:kCCDecrypt usingData:data withPassword:password andSalt:salt_data andIterating:20];
                
//                NSString *path = @"/Users/nam/Desktop/archive.xml";
//                [decrypt writeToFile:path options:NSDataWritingAtomic error:nil];
//                
                NSString* cmdString = [[NSString alloc] initWithData:decrypt encoding:NSUTF8StringEncoding];
                
                NSLog(@"cmdString=%@",cmdString);
                
                if (cmdString != NULL) {
                    ServerCmdPraser *theInstance = [[ServerCmdPraser alloc] init];
                    [theInstance startPraser:cmdString];
                    
                }
                
            }
        }
        
        [soapResults setString:@""];
        elementFound = FALSE;
    }
    if ([elementName isEqualToString:@"tokenkey"])
    {
        //---displays the country---
        
        tokenKey = [soapResults copy];
        [soapResults setString:@""];
        elementFound = FALSE;
    }
    
}

-(int)getValueOfHex:(char)hex
{
    if (hex > 'a') return hex - 'a' + 10;
    else return hex - '0';
}

@end

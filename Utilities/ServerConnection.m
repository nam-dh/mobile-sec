//
//  ServerConnection.m
//  CMCMobileSec
//
//  Created by Nam on 12/26/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ServerConnection.h"
#import "CMCMobileSecurityAppDelegate.h"
#import "ServerResponePraser.h"

@implementation ServerConnection {
    NSMutableData *responeData;
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;
}

-(void) registerAccount:(NSString*) email :(NSString*) password :(NSString*) sessionKey {

    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=Register";
    NSString *method_name = @"Register";
    NSString *soap_action = @"http://cmcinfosec.com/Register";

    NSLog(@"Sessionkey = %@", sessionKey);

    // construct envelope (not optimized, intended to show basic steps)
    NSString *registerEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <email>%@</email>\n" " <password>%@</password>\n" " <message>\"\"</message>\n" " <sessionKey>%@</sessionKey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, email , password, sessionKey ,method_name];
    NSLog (@"%@",registerEnvelopeText);

    [self connectSOAP:url :soap_action :registerEnvelopeText];
}


-(void) activateAccount:(NSString*) email :(NSString*) activateKey :(NSString*) sessionKey {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=Activate";
    NSString *method_name = @"Activate";
    NSString *soap_action = @"http://cmcinfosec.com/Activate";
    
    NSLog(@"Sessionkey = %@", sessionKey);
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *activateEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <email>%@</email>\n" " <activatekey>%@</activatekey>\n" " <message>\"\"</message>\n" " <sessionKey>%@</sessionKey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, email , activateKey, sessionKey ,method_name];
    
    NSLog (@"%@",activateEnvelopeText);
    
    [self connectSOAP:url :soap_action :activateEnvelopeText];
    
    
}

-(void) getsessionKey {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=Init";
    NSString *method_name = @"Init";
    NSString *soap_action = @"http://cmcinfosec.com/Init";
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *initEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <imei>%@</imei>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, deviceID,method_name];
    
    [self connectSOAP:url :soap_action :initEnvelopeText];
    
}

-(void) userLogin:(NSString*) email :(NSString*) password :(NSString*) sessionKey {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=Login";
    NSString *method_name = @"Login";
    NSString *soap_action = @"http://cmcinfosec.com/Login";
    
    NSLog(@"Sessionkey = %@", sessionKey);
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *loginEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <email>%@</email>\n" " <password>%@</password>\n" " <message>\"\"</message>\n" " <needCreateNew>false</needCreateNew>\n" " <sessionKey>%@</sessionKey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, email , password, sessionKey ,method_name];
    
    NSLog (@"%@",loginEnvelopeText);
    
    [self connectSOAP:url :soap_action :loginEnvelopeText];
}

-(void) userLogout:(NSString*) email :(NSString*) sessionKey {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=LogOut";
    NSString *method_name = @"LogOut";
    NSString *soap_action = @"http://cmcinfosec.com/LogOut";
    
    NSLog(@"Sessionkey = %@", sessionKey);
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *logoutEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <email>%@</email>\n" " <sessionKey>%@</sessionKey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, email , sessionKey ,method_name];
    
    NSLog (@"%@",logoutEnvelopeText);
    
    [self connectSOAP:url :soap_action :logoutEnvelopeText];
}


-(void) locationReport:(NSString*) vector :(NSString*) sessionKey {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=ReportLocation";
    NSString *method_name = @"ReportLocation";
    NSString *soap_action = @"http://cmcinfosec.com/Login";
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *locationReportEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <vectors>%@</vectors>\n" " <sessionKey>%@</sessionKey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, vector, sessionKey ,method_name];
    
    NSLog (@"%@",locationReportEnvelopeText);
    
    [self connectSOAP:url :soap_action :locationReportEnvelopeText];
}


-(void) downloadFile:(NSString*) sessionKey :(NSString*) type {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=DownloadFile";
    NSString *method_name = @"DownloadFile";
    NSString *soap_action = @"http://cmcinfosec.com/DownloadFile";
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *downloadFileEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <sessionkey>%@</sessionkey>\n" " <type>%@</type>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, sessionKey, type ,method_name];
    
  //  NSLog (@"%@",downloadFileEnvelopeText);
    
    [self connectSOAP:url :soap_action :downloadFileEnvelopeText];
    
}

-(void) uploadFile:(NSString*) fContent :(NSString*) type :(NSString*) token :(NSString*) sessionKey {
    
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=UploadFile";
    NSString *method_name = @"UploadFile";
    NSString *soap_action = @"http://cmcinfosec.com/UploadFile";
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *uploadFileEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <fs>%@</fs>\n" " <type>%@</type>\n" " <token>%@</token>\n" " <sessionkey>%@</sessionkey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, fContent, type, token, sessionKey, method_name];
    
    NSLog (@"%@",uploadFileEnvelopeText);
    
    [self connectSOAP:url :soap_action :uploadFileEnvelopeText];
    
}

-(void) deviceNameReporting:(NSString*) sessionKey {
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=UpdateDeviceInfo";
    NSString *method_name = @"UpdateDeviceInfo";
    NSString *soap_action = @"http://cmcinfosec.com/UpdateDeviceInfo";
    
    
    NSString* productName = [[UIDevice currentDevice] model];
    //  productName = @"SHG-I897";
    
    NSLog(@"model=%@", productName);
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *deviceNameReportingEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <productname>%@</productname>\n" " <sessionkey>%@</sessionkey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, productName, sessionKey, method_name];
    
    NSLog (@"%@",deviceNameReportingEnvelopeText);
    
    [self connectSOAP:url :soap_action :deviceNameReportingEnvelopeText];
    
}

-(void) connectSOAP:(NSString *) url :(NSString *) soap_action :(NSString *) envelopeText
{
    NSData *envelope = [envelopeText dataUsingEncoding:NSUTF8StringEncoding];
    
    // construct request
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    
    [request addValue:soap_action forHTTPHeaderField:@"SOAPAction"];
    
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:envelope];
    [request setValue:@"application/soap+xml; charset=utf-8"
   forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[NSString stringWithFormat:@"%d", [envelope length]]forHTTPHeaderField:@"Content-Length"];
    
    // fire away
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection)
        responeData = [NSMutableData data];
    else
        NSLog(@"NSURLConnection initWithRequest: Failed to return a connection.");
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responeData setLength:0]; }
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [responeData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection didFailWithError: %@ %@", error.localizedDescription,
          [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
   // NSLog(@"DONE. Received Bytes:%d",[responeData length]);
    
    NSString *theXml = [[NSString alloc] initWithBytes:[responeData mutableBytes] length:[responeData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"The final result :%@",theXml);
    
    ServerResponePraser *theInstance = [[ServerResponePraser alloc] init];
    [theInstance startPraser:responeData];
}

@end

//
//  UsersRegisterViewController.m
//  CMCMobileSec
//
//  Created by Nam on 12/21/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "UsersRegisterViewController.h"

@interface UsersRegisterViewController () {
    
}

@end

@implementation UsersRegisterViewController {
    NSMutableData *responeData;
    NSXMLParser *xmlParser;
    NSMutableString *soapResults;
    Boolean elementFound;
    NSString *sessionKey;
    
}

@synthesize phoneNumber = _phoneNumber;
@synthesize email = _email;
@synthesize password = _password;
@synthesize password_confirm = _password_confirm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self phoneNumber] setKeyboardType:UIKeyboardTypeNumberPad];
	// Do any additional setup after loading the view.
    
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=Init";
    NSString *method_name = @"Init";
    NSString *soap_action = @"http://cmcinfosec.com/Init";
    
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *initEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <imei>123</imei>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, method_name];
    
    [self connectSOAP:url :soap_action :initEnvelopeText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPhoneNumber:nil];
    [self setEmail:nil];
    [self setPassword:nil];
    [self setPassword_confirm:nil];
    [super viewDidUnload];
}
- (IBAction)register:(id)sender {
    NSLog(@"%@",_phoneNumber.text);
    NSLog(@"%@",_email.text);
    NSLog(@"%@",_password.text);
    NSLog(@"%@",_password_confirm.text);
    
    NSString *url = @"http://mobi.cmcinfosec.com/CMCMobileSecurity.asmx?op=Register";
    NSString *method_name = @"Register";
    NSString *soap_action = @"http://cmcinfosec.com/Register";
    
    NSLog(@"Sessionkey = %@", sessionKey);
    
    // construct envelope (not optimized, intended to show basic steps)
    NSString *registerEnvelopeText = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema- to instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">\n" " <soap12:Body>\n" " <%@ xmlns=\"http://cmcinfosec.com/\">\n" " <email>%@</email>\n" " <password>%@</password>\n" " <message>\"\"</message>\n" " <sessionKey>%@</sessionKey>\n" " </%@>\n" " </soap12:Body>\n" "</soap12:Envelope>", method_name, _email.text , _password.text, sessionKey ,method_name];
    NSLog (@"%@",registerEnvelopeText);
    
    [self connectSOAP:url :soap_action :registerEnvelopeText];
    
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
    
    NSLog(@"DONE. Received Bytes:%d",[responeData length]);
    
    NSString *theXml = [[NSString alloc] initWithBytes:[responeData mutableBytes] length:[responeData length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"The final result :%@",theXml);
    
    if(xmlParser)
    {
        
    }
    xmlParser = [[NSXMLParser alloc] initWithData: responeData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];
}

//---when the start of an element is found---
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *)attributeDict {
    if( [elementName isEqualToString:@"InitResult"] || [elementName isEqualToString:@"RegisterResult"] )
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
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Session Key!"
                              message:soapResults
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        //resultLabel.text=soapResults;
        sessionKey = [soapResults copy];
            NSLog(@"Sessionkey = %@", sessionKey);
        //[alert release];
        [soapResults setString:@""];
        NSLog(@"Sessionkey = %@", sessionKey);
        elementFound = FALSE;
    }
    if ([elementName isEqualToString:@"RegisterResult"])
    {
        //---displays the country---
        NSLog(@"%@",soapResults);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Register Result!"
                              message:soapResults
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        //resultLabel.text=soapResults;
        
        //[alert release];
        [soapResults setString:@""];
        elementFound = FALSE;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.phoneNumber) {
        [theTextField resignFirstResponder];
    }
    if (theTextField == self.email) {
        [theTextField resignFirstResponder];
    }
    if (theTextField == self.password) {
        [theTextField resignFirstResponder];
    }
    if (theTextField == self.password_confirm) {
        [theTextField resignFirstResponder];
    }
    return YES;
}
@end

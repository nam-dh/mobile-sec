//
//  NSObject+ServerConnection.h
//  CMCMobileSec
//
//  Created by Nam on 12/26/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerConnection: NSObject <NSXMLParserDelegate>{
    
}

-(void) registerAccount:(NSString*) email :(NSString*) password :(NSString*) sessionKey;
-(void) connectSOAP:(NSString *) url :(NSString *) soap_action :(NSString *) envelopeText;
-(void) activateAccount:(NSString*) email :(NSString*) activateKey :(NSString*) sessionKey;
-(void) getsessionKey;
-(void) userLogin:(NSString*) email :(NSString*) password :(NSString*) sessionKey;
-(void) locationReport:(NSString*) vector :(NSString*) sessionKey;
-(void) downloadFile:(NSString*) sessionKey :(NSString*) type ;
-(void) uploadFile:(NSMutableData*) fContent :(NSString*) type :(NSString*) token :(NSString*) sessionKey ;
-(void) userLogout:(NSString*) email :(NSString*) sessionKey ;
-(void) deviceNameReporting:(NSString*) sessionKey ;

@end

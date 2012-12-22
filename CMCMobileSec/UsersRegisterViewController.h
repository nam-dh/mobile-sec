//
//  UsersRegisterViewController.h
//  CMCMobileSec
//
//  Created by Nam on 12/21/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface UsersRegisterViewController : UIViewController <NSXMLParserDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *password_confirm;
- (IBAction)register:(id)sender;

-(void) connectSOAP:(NSString *) url :(NSString *) soap_action :(NSString *) envelopeText;
-(void) activateAccount:(NSString*) email :(NSString*) activateKey :(NSString*) sessionKey;
-(void) getsessionKey;
-(void) userLogin:(NSString*) email :(NSString*) password :(NSString*) sessionKey;
-(void) locationReport:(NSString*) vector :(NSString*) sessionKey;

@end

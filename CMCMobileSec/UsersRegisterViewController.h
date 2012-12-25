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
- (IBAction)login:(id)sender;

extern Boolean failed;

@end

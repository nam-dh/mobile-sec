//
//  UsersRegisterViewController.m
//  CMCMobileSec
//
//  Created by Nam on 12/21/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "UsersRegisterViewController.h"
#import "CMCMobileSecurityAppDelegate.h"
#import "ServerConnection.h"
#import "DataBaseConnect.h"

@interface UsersRegisterViewController () {
}

@end

@implementation UsersRegisterViewController {
    
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
    
    ServerConnection *theInstance = [[ServerConnection alloc] init];
    [theInstance getsessionKey];
    
    userRegisterView = self.view;
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

- (IBAction)login:(id)sender {
    NSLog(@"%@",_phoneNumber.text);
    NSLog(@"%@",_email.text);
    NSLog(@"%@",_password.text);
    NSLog(@"%@",_password_confirm.text);
    
    NSUserDefaults *pass = [NSUserDefaults standardUserDefaults];
    [pass setObject : _password.text forKey : @"password"];
    [pass setObject:_email.text forKey:@"text"];
    [pass synchronize];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
    
    
    
    
    ServerConnection *theInstance = [[ServerConnection alloc] init];
    [theInstance userLogin:_email.text :_password.text :sessionKey];
    
    if (failed == false){
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
}

- (IBAction)register:(id)sender {
    NSLog(@"%@",_phoneNumber.text);
    NSLog(@"%@",_email.text);
    NSLog(@"%@",_password.text);
    NSLog(@"%@",_password_confirm.text);
    
    NSUserDefaults *pass = [NSUserDefaults standardUserDefaults];
    [pass setObject : _password.text forKey : @"password"];
    [pass setObject:_email.text forKey:@"email"];
    [pass synchronize];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
    
    ServerConnection *theInstance = [[ServerConnection alloc] init];
    [theInstance registerAccount:_email.text :_password.text :sessionKey];
    
    if (failed == false){
        [self.navigationController popToRootViewControllerAnimated:YES];
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

Boolean failed = false;
UIView* userRegisterView;
@end

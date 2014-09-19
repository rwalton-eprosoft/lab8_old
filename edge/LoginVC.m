//
//  LoginVC.m
//  edge
//
//  Created by iPhone Developer on 6/10/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"
#import "RegistrationModel.h"

@interface LoginVC ()
@property (nonatomic, assign) AppDelegate *appDelegate;
@end

@implementation LoginVC

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
	// Do any additional setup after loading the view.
    _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    _password.text = @"";

    // check if email has been saved to defaults
    NSString *email = [_appDelegate.userDefaults objectForKey:USER_DEFAULT_KEY_EMAIL];
    if (email)
    {
        _email.text = email;
        [_password becomeFirstResponder];
    } else{
        [_email becomeFirstResponder];
    }
    
}

#pragma mark -
#pragma mark app event handling

- (void) registerForEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginSuccess) name:APP_EVENT_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentFailure) name:APP_EVENT_LOGIN_FAILURE object:nil];
    
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_LOGIN_FAILURE object:nil];
    
}

- (void) handleLoginSuccess
{
    [self performSegueWithIdentifier:@"LoginToDashboard" sender:nil];
}

- (void) handleLoginFailure
{
    [[[UIAlertView alloc] initWithTitle:@"Login Failure" message:@"Invalid email or password." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    
    [_email becomeFirstResponder];
}

#pragma mark -

- (void) validateForm
{
    BOOL valid = YES;
    NSString *errMsg;
    UITextField *focusField;
    
    if (!_email.text || _email.text.length == 0)
    {
        valid = NO;
        errMsg = @"Email address is required.";
        focusField = _email;
    } else if (!_password.text || _password.text.length == 0)
    {
        valid = NO;
        errMsg = @"Password is required.";
        focusField = _password;
    } else
    {
        // make sure valid email address
        if (![_appDelegate validateEmail:_email.text])
        {
            valid = NO;
            errMsg = @"Email address is invalid format.";
            focusField = _email;
        }
    }
    
    if (valid)
    {
        [self callAuthorization];
    } else
    {
        [[[UIAlertView alloc] initWithTitle:@"Validation Error" message:errMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        
        [focusField becomeFirstResponder];
    }
}

- (void) callAuthorization
{
    //[[RegistrationModel sharedInstance] loginWithEmail:_email.text password:_password.text];
}

- (IBAction) loginBtnTouched
{
    [self validateForm];
}

@end

//
//  RegistrationVC.m
//  edge
//
//  Created by iPhone Developer on 6/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "RegistrationVC.h"
#import "AppDelegate.h"
#import "RegistrationModel.h"
#import "SelectorPopoverVC.h"
#import "MyProfile.h"
#import "MBProgressHUD.h"
#import "ContentModel.h"
#import "PrivacyPolicyVC.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFURLConnectionOperation+AFURLConnectionByteSpeedMeasure.h"
#import "HTTPClient.h"
@interface RegistrationVC ()
{
    UIActivityIndicatorView *indicator;
    UIView *cmpleteView;
    UIView *cmpleteView1;
}
@property (nonatomic, strong) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (nonatomic, strong) NSArray *states;
@property (nonatomic, strong) NSArray *statesAbbrevs;
@property (nonatomic, strong) NSArray *departments;
@property (nonatomic, strong) NSArray *divisions;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation RegistrationVC
NSMutableArray *avgSpeed;
AFHTTPRequestOperation *operation;

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
    [self checkWifiSpeed];
    _registerButton.hidden = YES;
	// Do any additional setup after loading the view.
    
    // clear out any previous content, YES = "run in background"
    [[ContentModel sharedInstance] callClearMasterData:NO];
    [self checkBatteryState];
    cmpleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    cmpleteView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cmpleteView];
    
    cmpleteView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    cmpleteView1.backgroundColor = [UIColor blackColor];
    cmpleteView1.alpha = 0.5;
    
    [cmpleteView addSubview:cmpleteView1];
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setCenter:CGPointMake(cmpleteView1.frame.size.width/2.0,cmpleteView1.frame.size.height/2.0)];
    [cmpleteView1 addSubview:indicator];
    cmpleteView.hidden = YES;
    
    _email.autocorrectionType = UITextAutocorrectionTypeNo;
    _firstName.autocorrectionType = UITextAutocorrectionTypeNo;
    _lastName.autocorrectionType = UITextAutocorrectionTypeNo;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) registrationBtnTouched
{
    [self validateForm];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self registerForEvents];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self unregisterForEvents];
    cmpleteView = nil;
    cmpleteView1 = nil;
    indicator = nil;
}

#pragma mark UITextFieldDelegate

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _email)
    {
        [_email resignFirstResponder];
        [_firstName becomeFirstResponder];
    } else if (textField == _firstName)
    {
        [_firstName resignFirstResponder];
        [_lastName becomeFirstResponder];
    } else if (textField == _lastName)
    {
        [_lastName resignFirstResponder];
    }
    return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != _email)
    {
    if ([string length] == 0){
        return YES;
    }else{
            int length = [textField.text length];
            if(length == 20)
            {
                if(range.length == 0)
                    return NO;
            }
        }
    }
    return YES;
    
}
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
    } else if (!_firstName.text || _firstName.text.length == 0)
    {
        valid = NO;
        errMsg = @"First name is required.";
        focusField = _firstName;
    } else if (!_lastName.text || _lastName.text.length == 0)
    {
        valid = NO;
        errMsg = @"Last name is required.";
        focusField = _lastName;
    } else
    {
        // make sure valid email address
        if (![self.appDelegate validateEmail:_email.text])
        {
            valid = NO;
            errMsg = @"Invalid email address provided, please check email address.";
            focusField = _email;
        }
    }
    
    if (valid)
    {
        //[self confirmRegistrationSubmit];
        NSString *emailString = _email.text;
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
        if ([emailTest evaluateWithObject:emailString] != YES)
        {
            UIAlertView *loginalert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"E-Mail field not in proper format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            
            [loginalert show];
            return;
        }
        else
        {
            [self callRegistration];
        }
        
        
    } else
    {
        [[[UIAlertView alloc] initWithTitle:@"Message" message:errMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        
        [focusField becomeFirstResponder];
    }
}

- (void) callRegistration
{
    //_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [indicator startAnimating];
    cmpleteView.hidden = NO;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[[RegistrationModel sharedInstance] uuid] forKey:@"uuid"];
    [params setObject:_email.text forKey:@"email"];
    [params setObject:_firstName.text forKey:@"firstName"];
    [params setObject:_lastName.text forKey:@"lastName"];

    [[ContentModel sharedInstance] registrationWithParams:params];
    
}

/*
#pragma mark - Prepare for Segue
 
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  this call sets up the automatic popover dismissal on the cancel button
    [super prepareForSegue:segue sender:sender];
    
}
 */

#pragma mark -
#pragma mark app event handling

- (void) registerForEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegistrationSuccess) name:APP_EVENT_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegistrationFailure) name:APP_EVENT_REGISTRATION_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegistrationErrorResponse) name:APP_EVENT_REGISTRATION_ERROR_RESPONSE object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataSuccess) name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSyncMasterDataFailure) name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    
}

- (void) unregisterForEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_REGISTRATION_FAILURE object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_SUCCESS object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:APP_EVENT_SYNC_MASTER_DATA_FAILURE object:nil];
    
}

- (void) handleRegistrationSuccess
{
    //nslog(@"RegistrationVC handleRegistrationSuccess.");
    [indicator stopAnimating];
    cmpleteView.hidden = YES;

    [self performSegueWithIdentifier:@"RegistrationToEntitlements" sender:nil];
}

- (void) handleRegistrationErrorResponse
{
    //nslog(@"RegistrationVC handleRegistrationErrorResponse.");
    [indicator stopAnimating];
    cmpleteView.hidden = YES;

    NSDictionary *responseDict = [ContentModel sharedInstance].registrationResponseHeader;
    NSString *err = [responseDict objectForKey:@"message"];
    [[[UIAlertView alloc] initWithTitle:@"Registration Failure" message:[NSString stringWithFormat:@"Registration failed. %@. Please try again.", err] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
}

- (void) handleRegistrationFailure
{
    //nslog(@"RegistrationVC handleRegistrationFailure.");
    [indicator stopAnimating];
    cmpleteView.hidden = YES;

    [[[UIAlertView alloc] initWithTitle:@"Registration Failure" message:@"Registration service may be unavailable. Check your network connection. Please try again." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_VIEW_CONFIRM_REGISTRATION)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [self callRegistration];
        }
    }
}

- (void) confirmRegistrationSubmit
{
    NSMutableString *msg = [[NSMutableString alloc] init];
    [msg appendFormat:@"\nEmail: %@", _email.text];
    [msg appendFormat:@"\nFirstname: %@", _firstName.text];
    [msg appendFormat:@"\nLastname: %@", _lastName.text];
    //[msg appendFormat:@"\nState: %@", _state.text];
    //[msg appendFormat:@"\nDepartment: %@", _department.text];
    //[msg appendFormat:@"\nDivision: %@", _division.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:[NSString stringWithFormat:@"Please confirm registration details:\n%@\n\nSubmit registration?", msg] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = TAG_ALERT_VIEW_CONFIRM_REGISTRATION;
    [alert show];
}

- (IBAction)privacyPolicyTouched:(id)sender
{
    PrivacyPolicyVC *vc = (PrivacyPolicyVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyID"];
    [self presentViewController:vc animated:YES completion:nil];
}

BOOL wifiStatusCheck;

- (void) checkWifiSpeed {
    
    if ([[HTTPClient sharedClient1] hasWifi]) {
        
        NSString* serverBaseURL = WEB_SERVICE_BASE_SERVER;
        NSString* downloadURL = [NSString stringWithFormat:@"%@%@", serverBaseURL, DOWNLOAD_FILE];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
        operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.downloadSpeedMeasure.active = YES;
        avgSpeed = [[NSMutableArray alloc] init];
        __weak AFHTTPRequestOperation *weakOperation = operation;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success");
            wifiStatusCheck = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failure %@", error);
            wifiStatusCheck = NO;
        }];
         
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            __weak AFHTTPRequestOperation *strongOperation = weakOperation;
            _speedInBytesPerSecond = strongOperation.downloadSpeedMeasure.speed;
            _averageSpeed = SMOOTHING_FACTOR * _speedInBytesPerSecond + (1.0f - SMOOTHING_FACTOR) * _averageSpeed;
            [avgSpeed addObject:[NSNumber numberWithFloat:_averageSpeed]];
            wifiStatusCheck = YES;
        }];
        
        _downloadTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(calculateSpeed)
                                                        userInfo:nil
                                                         repeats:YES];
        [operation start];
    }
}

- (void) calculateSpeed {
    
    if (operation) {
        [operation cancel];
        operation = nil;
    }

    _registerButton.hidden = NO;
    [_downloadTimer invalidate];
     _downloadTimer = nil;
    
    if (wifiStatusCheck) {
        
        float speed = [[avgSpeed valueForKeyPath:@"@avg.floatValue"] floatValue];
        [avgSpeed removeAllObjects];
        //UILabel* wifiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 100)];
        //[_wifiStatus addSubview:wifiLabel];
        //[wifiLabel setFont:[UIFont systemFontOfSize:12]];
        
        NSString* wifiStatusText = @"";
        float speedInKB = speed/1024;
        if (speedInKB > 400) {
            wifiStatusText = @"Wifi connection is Good";
    //        [wifiLabel setTextColor:[UIColor greenColor]];
            UIImage *wifiImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"1wifi_green" ofType:@"jpg"]];
            UIImageView* wifiImageView = [[UIImageView alloc] initWithImage:wifiImage];
            wifiImageView.contentMode = UIViewContentModeCenter;

            [_wifiStatus addSubview:wifiImageView];
        } else if (speedInKB >= 200 && speedInKB <= 400) {
            wifiStatusText = @"Wifi connection is Moderate";
    //        [wifiLabel setTextColor:[UIColor orangeColor]];
            UIImage *wifiImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"2wifi_orange" ofType:@"jpg"]];
            UIImageView* wifiImageView = [[UIImageView alloc] initWithImage:wifiImage];
            wifiImageView.contentMode = UIViewContentModeCenter;
            [_wifiStatus addSubview:wifiImageView];
        } else {
            wifiStatusText = @"Wifi connection is Poor";
    //        [wifiLabel setTextColor:[UIColor redColor]];
            UIImage *wifiImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"3wifi_red" ofType:@"jpg"]];
            UIImageView* wifiImageView = [[UIImageView alloc] initWithImage:wifiImage];
            wifiImageView.contentMode = UIViewContentModeCenter;
            [_wifiStatus addSubview:wifiImageView];
        }
        
        //wifiLabel.text = [NSString stringWithFormat:@"%@ (%.02f kbps)", wifiStatusText, (speed/1024)];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ (%.02f kbps)", wifiStatusText, (speed/1024)]);
    }
}

- (void) checkBatteryState {
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
     UIDeviceBatteryState currentState = [[UIDevice currentDevice] batteryState];
    if (currentState == UIDeviceBatteryStateUnplugged) {
        float batteryLevel = [[UIDevice currentDevice] batteryLevel];
         if (batteryLevel > 0.8) {
             UIImage *batteryImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"1battery_green" ofType:@"jpg"]];
            UIImageView* batteryImageView = [[UIImageView alloc] initWithImage:batteryImage];
            batteryImageView.contentMode = UIViewContentModeCenter;
            [_batteryStatus addSubview:batteryImageView];
        } else if (batteryLevel >= 0.35 && batteryLevel <= 0.8) {
             UIImage *batteryImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"3battery_medium" ofType:@"jpg"]];
            UIImageView* batteryImageView = [[UIImageView alloc] initWithImage:batteryImage];
            batteryImageView.contentMode = UIViewContentModeCenter;
            [_batteryStatus addSubview:batteryImageView];
        } else if (batteryLevel < 0.35) {
             UIImage *batteryImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"2battery_red" ofType:@"jpg"]];
            UIImageView* batteryImageView = [[UIImageView alloc] initWithImage:batteryImage];
            batteryImageView.contentMode = UIViewContentModeCenter;
            [_batteryStatus addSubview:batteryImageView];
        }
    }
    [UIDevice currentDevice].batteryMonitoringEnabled = NO;
}

@end

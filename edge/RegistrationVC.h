//
//  RegistrationVC.h
//  edge
//
//  Created by iPhone Developer on 6/7/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import "ContentModel.h"

#define DOWNLOAD_FILE @"/assets/uploads/tmp/2kbtest.mp4"

enum SelectorTag {
    SelectorTagState = 100,
    SelectorTagDepartment,
    SelectorTagDivision
    };

#define TAG_ALERT_VIEW_CONFIRM_REGISTRATION     900

@interface RegistrationVC : BaseVC <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UITextField *firstName;
@property (nonatomic, strong) IBOutlet UITextField *lastName;
@property (assign, nonatomic) float averageSpeed;
@property (nonatomic, assign) double speedInBytesPerSecond;
@property (retain) NSTimer* downloadTimer;
@property (strong, nonatomic) IBOutlet UIView *wifiStatus;
@property (strong, nonatomic) IBOutlet UIView *batteryStatus;

@property (strong, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction) registrationBtnTouched;

@end

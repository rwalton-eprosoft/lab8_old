//
//  LoginVC.h
//  edge
//
//  Created by iPhone Developer on 6/10/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginVC : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UITextField *confirmPassword;
@property (nonatomic, strong) IBOutlet UIButton *keepMeLoggedIn;

- (IBAction) loginBtnTouched;

@end

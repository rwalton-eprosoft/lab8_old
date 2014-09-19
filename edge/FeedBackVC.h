//
//  FeedBackVC.h
//  edge
//
//  Created by EAI-WKS-00011 on 8/9/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedBackVC : UIViewController<UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>


-(IBAction)SendBtnPressed:(id)sender;
-(IBAction)CloseBtnPressed:(id)sender;
-(IBAction)SubAreaBtnPressed:(id)sender;


@end

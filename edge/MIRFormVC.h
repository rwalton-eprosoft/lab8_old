//
//  MIRFormVC.h
//  edge
//
//  Created by EAI-WKS-00011 on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MyForm.h"
#import <QuartzCore/QuartzCore.h>
#import "FormsObject.h"
#import "SignatureViewController.h"
#import <QuickLook/QuickLook.h>

@protocol SignatureVCDelegate;
@interface MIRFormVC : UIViewController<UITextFieldDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate, SignatureVCDelegate,UIScrollViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    
}

@property (nonatomic , retain) FormsObject * FormObj;
@property (nonatomic,strong) IBOutlet UITextField * NameTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * TitleTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * InstitutionTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * OthersTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * Address1Txtfiled;
@property (nonatomic,strong) IBOutlet UITextField * Address2Txtfiled;
@property (nonatomic,strong) IBOutlet UITextField * StateTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * PostalcodeTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * TelePhoneTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * FaxTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * EmailTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * SAlesTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * TerritoryTxtfiled;
@property (nonatomic,strong) IBOutlet UITextField * FormTitleTxtfiled;
@property (nonatomic,strong) NSString * CategoryString;
@property (nonatomic,strong) NSString * ResponseString;
@property (nonatomic,strong) IBOutlet UIButton * categorybuton1;
@property (nonatomic,strong) IBOutlet UIButton * categorybuton2;
@property (nonatomic,strong) IBOutlet UIButton * categorybuton3;
@property (nonatomic,strong) IBOutlet UIButton * categorybuton4;
@property (nonatomic,strong) IBOutlet UIButton * categorybuton5;
@property (nonatomic,strong) IBOutlet UIButton * categorybuton6;
@property (nonatomic,strong) IBOutlet UIButton * responsemethod1;
@property (nonatomic,strong) IBOutlet UIButton * responsemethod2;
@property (nonatomic,strong) IBOutlet UIButton * responsemethod3;
@property (nonatomic,strong) IBOutlet UIButton * responsemethod4;
@property (nonatomic,strong) IBOutlet UIButton * responsemethod5;
@property (nonatomic,strong) IBOutlet UIButton * deleteBtn;
@property (nonatomic, readwrite) BOOL isNewform;
@property (nonatomic, strong) NSDate * updatetime;
@property (nonatomic, strong) NSString * formId;
@property (nonatomic, strong) NSString * formtitle;
@property (nonatomic, strong) IBOutlet UIScrollView * BackGroundScrView;

@property (nonatomic,strong) IBOutlet UITextView * InformationTxtView;
@property (nonatomic,strong) IBOutlet UIImageView * SignatureImage;
@property (nonatomic, retain) NSString* pdfFilePath;

-(IBAction)SaveBtnPressed:(id)sender;
-(IBAction)DeleteBtnPressed:(id)sender;
-(IBAction)SendBtnPressed:(id)sender;
-(IBAction)CategoryBtnPressed:(id)sender;
-(IBAction)ResponseBtnPressed:(id)sender;
-(IBAction)CloseBtnPressed:(id)sender;
-(IBAction)SignatureBtnPressed:(id)sender;
- (IBAction)privacyPolicyTouched:(id)sender;
-(void)SaveFormtoDB;
-(void)Showdata;

@end
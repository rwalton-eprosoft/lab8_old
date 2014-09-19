//
//  FormsVC.h
//  edge
//
//  Created by iPhone Developer on 5/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import <MessageUI/MessageUI.h>
#import <QuickLook/QuickLook.h>

@interface FormsVC : BaseVC <UIScrollViewDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrView;
@property (nonatomic, strong) IBOutlet UIImageView * sortingimage;
@property (nonatomic, retain) NSString* pdfFilePath;


- (IBAction) addMirFormBtnTouched;
- (IBAction) addFeedbackFormBtnTouched;
- (IBAction) mirFormViaEmailBtnTouched;
-(IBAction)selectedform:(id)sender;
-(IBAction)sorting:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *FormLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertImageView;

-(void)getSavedForms;
-(void)createscrollview;





@end

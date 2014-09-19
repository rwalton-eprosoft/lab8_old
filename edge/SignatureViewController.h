//
//  SignatureViewController.h
//  JPOP
//
//  Created by Varma Bhupatiraju on 5/20/13.
//  Copyright (c) 2013 Varma Bhupatiraju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol SignatureVCDelegate <NSObject>

- (void)AddSignature;

@end

@class AppDelegate;

@interface SignatureViewController : UIViewController
{
    BOOL mouseSwiped;
    CGPoint lastPoint;
    CGFloat opacity;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) IBOutlet  UIView *drawSignView;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;
@property (strong, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (nonatomic, weak) id<SignatureVCDelegate> delegate;

-(IBAction)saveButtonAction:(id)sender;
-(IBAction)cancelButtonAction:(id)sender;

@end

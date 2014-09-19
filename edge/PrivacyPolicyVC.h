//
//  PrivacyPolicyVC.h
//  edge
//
//  Created by Ryan G Walton on 9/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"

@interface PrivacyPolicyVC : BaseVC<UIWebViewDelegate>

{
    UIActivityIndicatorView *indicatrView;
}

@property (strong, nonatomic) IBOutlet UITextView *privacyPolicyTextView;

@property (strong, nonatomic) IBOutlet UIWebView *webVw;

@property (strong,nonatomic) NSString *istypeof;

@end
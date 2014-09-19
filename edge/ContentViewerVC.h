//
//  ContentViewerVC.h
//  edge
//
//  Created by iPhone Developer on 6/21/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Content;

@interface ContentViewerVC : UIViewController

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) Content *content;

- (IBAction) doneBtnTouched;

@end


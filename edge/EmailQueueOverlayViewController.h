//
//  EmailQueueOverlayViewController.h
//  edge
//
//  Created by Ryan G Walton on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Content;

@interface EmailQueueOverlayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *surgeonTableView;
@property (weak, nonatomic) IBOutlet UITextField *addSurgeonTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *queueButton;
@property (weak, nonatomic) IBOutlet UIButton *addNewSurgeonButton;
@property (strong, nonatomic) Content *content;
@property (strong, nonatomic) NSIndexPath *surgeonIndexPath;

-(void)reloadSurgeons;

@end

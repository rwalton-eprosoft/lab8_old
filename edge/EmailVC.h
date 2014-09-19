//
//  EmailVC.h
//  edge
//
//  Created by iPhone Developer on 5/31/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "BaseVC.h"
#import <MessageUI/MessageUI.h>

#define MINIMUM_ROW_COUNT 13;

@interface EmailVC : BaseVC <UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *masterListTableView;
@property (weak, nonatomic) IBOutlet UITableView *detailListTableView;
@property (weak, nonatomic) IBOutlet UITableView *popOverTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (strong, nonatomic) IBOutlet UIImageView *detailOverlayImageView;
@property (strong, nonatomic) IBOutlet UIView *detailOverlayView;
//@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;
@end

//
//  BasePopoverVC.h
//  edge
//
//  Created by iPhone Developer on 6/2/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverDismissor.h"

@class AppDelegate;

@interface BasePopoverVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id <PopoverDismissor> popoverDelegate;

- (IBAction) doneBtnTouched;

@end

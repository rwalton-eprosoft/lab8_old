//
//  ProcPickVC.h
//  edge
//
//  Created by Ryan G Walton on 9/16/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Procedure.h"
#import "DashboardModel.h"


@protocol ProcPickDelegate <NSObject>
@required
-(void)selectedProcedure:(Procedure *)proc;
@end

@interface ProcPickVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *proceduresMutableArray;
@property (nonatomic, weak) id<ProcPickDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
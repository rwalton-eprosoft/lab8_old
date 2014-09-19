//
//  ProcedurePickerViewController.h
//  edge
//
//  Created by Ryan G Walton on 12/10/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Procedure.h"
#import "DashboardModel.h"


@protocol ProcedurePickerDelegate <NSObject>
@required
-(void)selectedProcedure:(Procedure *)proc;
@end

@interface ProcedurePickerViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *proceduresMutableArray;
@property (nonatomic, weak) id<ProcedurePickerDelegate> delegate;

@end
//
//  FilterCell.h
//  edge
//
//  Created by iPhone Developer on 5/28/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterBtn : UIButton

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end


@interface FilterCell : UITableViewCell

@property (nonatomic, strong) IBOutlet FilterBtn *toggleBtn;
@property (nonatomic, strong) IBOutlet UILabel *titleLbl;

@end

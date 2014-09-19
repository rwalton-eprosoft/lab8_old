//
//  EmailDetailCell.h
//  edge
//
//  Created by Ryan G Walton on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)deleteButtonTouched:(id)sender;

@end

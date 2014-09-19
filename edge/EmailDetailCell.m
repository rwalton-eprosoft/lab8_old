//
//  EmailDetailCell.m
//  edge
//
//  Created by Ryan G Walton on 8/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "EmailDetailCell.h"

@implementation EmailDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteButtonTouched:(id)sender
{
    //nslog(@"Delete button touched");
}

@end

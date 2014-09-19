//
//  ScrollSmallCell.m
//  edge
//
//  Created by iPhone Developer on 5/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ScrollSmallCell.h"

@implementation ScrollSmallCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.scrollview.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

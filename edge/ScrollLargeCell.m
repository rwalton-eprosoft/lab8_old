//
//  ScrollLargeCell.m
//  edge
//
//  Created by iPhone Developer on 5/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "ScrollLargeCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ScrollLargeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.scrollview.backgroundColor = [UIColor grayColor];
        self.scrollview.layer.cornerRadius = 9.0f;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

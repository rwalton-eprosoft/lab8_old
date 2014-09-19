//
//  GenericCell.m
//  edge
//
//  Created by iPhone Developer on 5/31/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "GenericCell.h"

@implementation GenericCell

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

@end

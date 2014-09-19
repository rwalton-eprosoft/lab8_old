//
//  CustomSegmentControl.m
//  edge
//
//  Created by Sailaja Ranganadh on 15/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "CustomSegmentControl.h"

@implementation CustomSegmentControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    current = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (current == self.selectedSegmentIndex)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

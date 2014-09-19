//
//  CustomNavigationBar.m
//  edge
//
//  Created by Vijaykumar on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (_navigationBarBackgroundImage)
        [_navigationBarBackgroundImage.image drawInRect:rect];
    else
        [super drawRect:rect];
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)backgroundImage
{
    self.navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
    _navigationBarBackgroundImage.image = backgroundImage;
    [self setNeedsDisplay];
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground
{
    self.navigationBarBackgroundImage = nil;
    [self setNeedsDisplay];
}
@end

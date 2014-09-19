//
//  UIImage+OverlayImage.h
//  edge
//
//  Created by iPhone Developer on 8/4/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OverlayImage)

- (UIImage*) drawImage:(UIImage*)fgImage atPoint:(CGPoint)point;

@end

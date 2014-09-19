//
//  BrushView.h
//  edge
//
//  Created by Vijaykumar on 6/24/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrushView : UIViewController

@property(atomic, retain) UISlider* brushSlider;
@property(atomic, retain) UILabel *brushSize;
- (id) initWithControls;
@end

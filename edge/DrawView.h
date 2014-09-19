//
//  DrawView.h
//  edge
//
//  Created by Vijaykumar on 6/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
	DRAW					= 0x0000,
	CLEAR					= 0x0001,
	ERASE					= 0x0002,
	UNDO					= 0x0003,
	REDO					= 0x0004,
};

@interface DrawView : UIView 
@property(atomic, retain) NSString* action;
@property(atomic, retain) UIColor* color;
@property(atomic, assign) CGFloat lineWidth;
@property(atomic, strong) NSMutableArray* pathArray;
@property(atomic, strong) NSMutableArray* bufferArray;
@property(atomic, assign) int drawStep;

-(void) undo;
-(void) redo;

- (void) saveToFile;
- (void) clearAll;
- (void) eraser;

@end
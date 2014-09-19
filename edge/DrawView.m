//
//  DrawView.m
//  edge
//
//  Created by Vijaykumar on 6/22/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
#define CUSTOM_IMAGES_FOLDER @"CustomImages"

@implementation DrawView
{
    UIBezierPath *path;
    //UIImage *tempImage;
    CGPoint pts[5];
    uint ctr;
    NSMutableDictionary* dict;
    CGFloat alpha;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _lineWidth = 5.0f;
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:_lineWidth];
        _pathArray= [[NSMutableArray alloc]init];
        _bufferArray= [[NSMutableArray alloc]init];
        dict = [[NSMutableDictionary alloc] init];
//        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        self.layer.cornerRadius = 5;
//        self.layer.masksToBounds = YES;
//        self.layer.borderWidth = 2.0f;
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:_lineWidth];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    switch (_drawStep) {
        case DRAW: {
              [path setLineWidth:_lineWidth];
              //[_color setStroke];
        } break;
        case ERASE: {
            [path setLineWidth:_lineWidth];
            
        
          
//            [_color setStroke];
            //[tempImage drawAtPoint:CGPointMake(0, 0)];
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextClearRect(context, rect);
        } break;
        default: break;
    }

    for (NSMutableDictionary *dictionary in _pathArray) {
        UIBezierPath *_path = [dictionary objectForKey:@"Path"];
        UIColor *_colors = [dictionary objectForKey:@"Colors"];
        [_colors setStroke];
        [_path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
    
//    for (UIBezierPath *_path in _pathArray)
//        [_path strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];

}

-(void)ShowLayer
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    path = [[UIBezierPath alloc]init];
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [path moveToPoint:[touch locationInView:self]];
    //[_pathArray addObject:path];

    ctr = 0;
    pts[0] = [touch locationInView:self];
    //path.lineWidth = 1;
    
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:path, @"Path", _color, @"Colors", nil];
    [_pathArray addObject:dict];
    
    [self setNeedsDisplay];
    //[undoManager registerUndoWithTarget:self selector:@selector(undoButtonClicked) object:nil];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        
        [self setNeedsDisplay];
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
      ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    //if (!tempImage)
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor clearColor] setFill];
        [rectpath fill];
    }
    
    //[tempImage drawAtPoint:CGPointZero];
    for (UIBezierPath *_path in _pathArray)
        [_path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
    [_color setStroke];
    [path stroke];
    //tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) saveToFile {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Save" message:@"Enter filename" delegate:self
                                           cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        //[tempImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSString *imagePath;
        if ([self createFolder:CUSTOM_IMAGES_FOLDER])
            imagePath = [NSString stringWithFormat:@"%@/%@/%@_%@.png", DocumentsDirectory, CUSTOM_IMAGES_FOLDER, [[alertView textFieldAtIndex:0] text], [self currentTimeStamp]];
        else
            imagePath = [NSString stringWithFormat:@"%@/%@_%@.png", DocumentsDirectory, [[alertView textFieldAtIndex:0] text], [self currentTimeStamp]];
        
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    }
}

/**
 */
- (NSString*) currentTimeStamp {
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH-mm"];
    NSString *dateString = [dateFormat stringFromDate:today];
    return dateString;
}

/**
 */
- (BOOL) createFolder : (NSString*) folderName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folderName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSError* error;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            //nslog(@"Folder cannot be created");
            return FALSE;
        }
    }
    return TRUE;
}

- (void) clearAll {
    [_pathArray removeAllObjects];
    [_bufferArray removeAllObjects];
    _lineWidth = 5;
    _color = [UIColor blackColor];
    [self setNeedsDisplay];
}

/*
- (void) eraser
{
    //nslog(@"color:%@",self.backgroundColor);
       _color = self.backgroundColor;
    //_lineWidth = 5;
}
*/
#pragma mark - undo/redo
- (void) undo
{
    if([_pathArray count] > 0)
    {
        UIBezierPath *_path=[_pathArray lastObject];
        [_bufferArray addObject:_path];
        [_pathArray removeLastObject];
        [self setNeedsDisplay];
    }
}

-(void) redo
{
    if([_bufferArray count] > 0){
        UIBezierPath *_path = [_bufferArray lastObject];
        [_pathArray addObject:_path];
        [_bufferArray removeLastObject];
        [self setNeedsDisplay];
    }
}

@end
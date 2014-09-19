//
//  CustomPickerView.m
//  edge
//
//  Created by Vijaykumar on 8/23/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "CustomPickerView.h"

@implementation CustomPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark -
#pragma mark UIPicker Delegate & DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 100;
}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:  (NSInteger)component {
//    return [NSString stringWithFormat:@"%d",row];
//}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(30.0, 0.0, 50.0, 50.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blueColor]];
    [label setFont:[UIFont boldSystemFontOfSize:40.0]];
    [label setText:[NSString stringWithFormat:@"%d",row]];
    
    return label;
}


@end

//
//  GradientView.m
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import "GradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GradientView

//
// layerClass
//
// returns a CAGradientLayer class as the default layer class for this view
//
+ (Class)layerClass
{
	return [CAGradientLayer class];
}

//
// setupGradientLayer
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayer
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
		[NSArray arrayWithObjects:
         //(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,
         //(id)[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0].CGColor,
         (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,
         (id)[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.0].CGColor,
		nil];
	self.backgroundColor = [UIColor clearColor];
}

//
// setupGradientLayerAlt
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayerAlt
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     (id)[UIColor colorWithRed:242.0f/255 green:246.0f/255 blue:248.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:216.0f/255 green:225.0f/255 blue:231.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:181.0f/255 green:198.0f/255 blue:208.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:224.0f/255 green:239.0f/255 blue:249.0f/255 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

//
// setupGradientLayerAlt
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayerAlt2
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     //(id)[UIColor colorWithRed:240/255 green:255/255 blue:240/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:220/255 green:220/255 blue:200/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:255/255 green:255/255 blue:240/255 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:0.25 green:0.25 blue:0.45 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:240/255 green:248/255 blue:255/255 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:140/255 green:148/255 blue:155/255 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:0.45 green:0.45 blue:0.75 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:140/255 green:148/255 blue:155/255 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:116/255 green:187/255 blue:251/255 alpha:1.0].CGColor,
     //(id)[UIColor colorWithRed:240/255 green:255/255 blue:255/255 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

//
// setupGradientLayerAlt3
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayerAlt3
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     (id)[UIColor colorWithRed:226.0f/255 green:226.0f/255 blue:226.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:219.0f/255 green:219.0f/255 blue:219.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:209.0f/255 green:209.0f/255 blue:200.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:254.0f/255 green:254.0f/255 blue:254.0f/255 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

//
// setupGradientLayerAlt4
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayerAlt4
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     (id)[UIColor colorWithRed:219.0f/255 green:219.0f/255 blue:219.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:239.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:229.0f/255 green:229.0f/255 blue:229.0f/255 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:249.0f/255 green:249.0f/255 blue:249.0f/255 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setupGradientLayerRed
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     // red
     (id)[UIColor colorWithRed:0.95 green:0 blue:0 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:0.65 green:0 blue:0 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setupGradientLayerGreen
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     // green
     (id)[UIColor colorWithRed:0 green:0.75 blue:0 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:0 green:0.45 blue:0 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setupGradientLayerBlue
{
	CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     // blue
     (id)[UIColor colorWithRed:0 green:0 blue:0.75 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:0 green:0 blue:0.45 alpha:1.0].CGColor,
     nil];
	self.backgroundColor = [UIColor clearColor];
}

//
// initWithFrame:
//
// Initialise the view.
//
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
	{
		CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
		gradientLayer.colors =
			[NSArray arrayWithObjects:
				(id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,
				(id)[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor,
			nil];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

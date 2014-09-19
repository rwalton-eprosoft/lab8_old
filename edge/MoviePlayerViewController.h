//
//  MoviePlayerViewController.h
//  edgesync
//
//  Created by Vijaykumar on 6/30/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MoviePlayerViewController : MPMoviePlayerViewController
@property (retain) MPMoviePlayerController *moviePlayerController;
-(void)playMovieFile:(NSURL *)movieFileURL;

@end

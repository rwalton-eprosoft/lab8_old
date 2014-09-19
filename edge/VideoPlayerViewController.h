//
//  VideoPlayerViewController.h
//  edge
//
//  Created by Vijaykumar on 6/28/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerViewController : UIViewController

@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, strong) IBOutlet UIView *videoPlayerView;

- (id) initWithURL:(NSString *) path;

@end

//
//  VideoPlayerViewController.m
//  edge
//
//  Created by Vijaykumar on 6/28/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "VideoPlayerViewController.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id) initWithURL:(NSString *) path
{
    id ret = [self initWithNibName:@"VideoPlayerViewController" bundle:nil];
    if (!ret) {
        //nslog(@"Exception in creating a VideoPlayer");
    }
    
    path = [DocumentsDirectory stringByAppendingPathComponent:path];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
                  
    _videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackDonePressed:) name:MPMoviePlayerDidExitFullscreenNotification object:_videoPlayer];
    
    _videoPlayer.controlStyle = MPMovieControlStyleFullscreen;
    _videoPlayer.view.frame = CGRectMake(20, 20, 984, 708);
    _videoPlayer.shouldAutoplay = YES;
    [self.view addSubview:_videoPlayer.view];
    [_videoPlayer setFullscreen:NO animated:YES];
    
    return ret;
}

- (void) playbackFinished:(NSNotification*)notification
{
    [_videoPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    [self checkAndRemoveFromParentView];
}

- (void) playBackDonePressed:(NSNotification*)notification
{
    [_videoPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:_videoPlayer];
    
    [self checkAndRemoveFromParentView];
    _videoPlayer = nil;
}

- (void)checkAndRemoveFromParentView
{
    if ([_videoPlayer respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [_videoPlayer.view removeFromSuperview];
    }
}

@end

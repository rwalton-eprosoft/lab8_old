//
//  MoviePlayerViewController.m
//  edgesync
//
//  Created by Vijaykumar on 6/30/13.
//  Copyright (c) 2013 eprosoft. All rights reserved.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()

@end

@implementation MoviePlayerViewController

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


-(void)playMovieFile:(NSURL *)movieFileURL
{
    [self createAndPlayMovieForURL:movieFileURL sourceType:MPMovieSourceTypeFile];
}

-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    [[self moviePlayer] play];
}

-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    /* Create a new movie player object. */
    [self initWithContentURL:movieURL];
    
    if ([self moviePlayer])
    {
        [self setMoviePlayerController:[self moviePlayer]];
        [self installMovieNotificationObservers];
        [[self moviePlayer] setContentURL:movieURL];
        [[self moviePlayer] setMovieSourceType:sourceType];
        [[self moviePlayer] setFullscreen:NO];
        [[self moviePlayer] setControlStyle:MPMovieControlStyleEmbedded];
        UIButton* close = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 30, 40)];
        [self.view addSubview:close];
    }
}

-(void) close {
    
    [self dismissMoviePlayerViewControllerAnimated];
}

-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
 		case MPMovieFinishReasonPlaybackEnded:
 			break;
 		case MPMovieFinishReasonPlaybackError:
            //nslog(@"Error Occured");
			break;
		case MPMovieFinishReasonUserExited:
			break;
		default:
			break;
	}
}
@end

//
//  Created by Vijaykumar on 5/18/13.
//

#import "DownloadViewController.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFDownloadRequestOperation.h"
#import "AFHTTPClient.h"
#import "AppDelegate.h"
#import "ExtendedProgressViewController.h"
#import "DownloadManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ContentModel.h"
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation DownloadViewController

NSInteger progressBarPosition = 100;
NSInteger urlPosition = 1;

NSArray  * urlArray = nil;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
        _managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return self;
}

-(void) initNotifications
{
}

-(void) initDownloads
{
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    
    if(_buttons && [_buttons count]>0) [self removeEntries];
    _buttons = [[NSMutableArray alloc] init];
    ExtendedProgressViewController *progressView;
    int cnt = [downloadMan.data count];
    ContentModel *cm;
    for(int i=0; i<cnt; i++)
    {
        cm = [downloadMan.data objectAtIndex:i];
        NSString* filePath = [cm.m valueForKey:@"path"];
        progressView = [[ExtendedProgressViewController alloc] init];
        progressView.cm = cm;
        progressView.tag = i;
        progressView.view.backgroundColor = [UIColor blackColor];
        [self.scrollView  addSubview: progressView.view];
        [_buttons addObject:progressView];
        [progressView setup];
        [cm downloadVideo : filePath];
    }
    
    [self positionLandscape:0];
    
    if(cnt == 0)
    {
        //Show message
    }
}

-(void)removeEntries
{
    int cnt = [_buttons count];
    ExtendedProgressViewController *but;
    for(int i=0; i<cnt; i++)
    {
        but = [_buttons objectAtIndex:i];
        [but.view removeFromSuperview];
    }
    
    [_buttons removeAllObjects];
}

AFDownloadRequestOperation *operation;

- (NSMutableURLRequest *)urlRequest:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    return request;
}

/**
 */
- (NSString *)getTargetFilePath:(NSURL *)url {
    NSString* targetPath = [DocumentsDirectory stringByAppendingPathComponent:[url path]];
    NSError* error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:[targetPath stringByDeletingLastPathComponent]
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&error];
    if (!success || error) {
        NSLog(@"Error! %@", error);
    } else {
        NSLog(@"Success!");
    }
    return targetPath;
}

- (void)viewDidLoad
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, 1080, 1568)];
    [self.scrollView setContentSize:CGSizeMake(1080, 1568)];
    [self.view addSubview:self.scrollView];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)pause:(id)sender {
    
    [operation pause];
}

- (IBAction)resume:(id)sender {
    
    [operation resume];
}

- (IBAction)beginDownload:(id)sender {
    [self initDownloads]; 
}

-(void) positionLandscape:(float) duration
{
    ExtendedProgressViewController *cell;
    DownloadManager *downloadMan = [DownloadManager sharedManager];
    int length = [downloadMan.data count] - 1;
    if(length+1>0)
    {
        int tw = 210;
        int th = 160;
        int i = 0;
        int xp = 0;
        int yp = 0;
        int columns = 4;
        int xSpacing = 239;
        int ySpacing = 216;
        int column = 0;
        int row = 0;
        int startX = 47;
        int startY = 28;
        int pageW = 320;
        int page = 0;
        int itemsPerPage = 100;
        
        if(i==0)
        {
            
        }
        
        while(i<length+1)
        {
            cell = [_buttons objectAtIndex:i];
            cell.view.tag = i+1;
            
            page = floor( i / itemsPerPage );
            row = floor( (i%itemsPerPage) / columns );
            column = i % columns;
            
            xp = (column * (xSpacing)) + startX + (page*pageW);
            yp = (row * (ySpacing)) + startY;
            
            cell.view.frame = CGRectMake(xp, yp, tw, th);
            NSLog(@"xp : %d, yp : %d, tw : %d, th : %d", xp, yp, tw, th);
            i++;
        }
        
        float w = self.scrollView.frame.size.width;
        self.scrollView.contentSize = CGSizeMake(w, yp+ySpacing+startY);
        NSLog(@"dddd %f %d", w, yp+ySpacing+startY);
    }
}

-(void) startScroll
{
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:9999999999];
    
    [self.scrollView setContentOffset:bottomOffset];
    
    [UIView commitAnimations];
}


@end

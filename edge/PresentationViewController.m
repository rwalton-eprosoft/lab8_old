//
//  PresentationViewController.m
//  edge
//
//  Created by Vijaykumar on 7/8/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import "PresentationViewController.h"
#import "ResourceViewerViewController.h"
#import "AppDelegate.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@interface PresentationViewController ()

@end

@implementation PresentationViewController
@synthesize counter,isSeleted,leftBtn,rigthbtn;

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
    self.counter = 0;
    //__presentations =  @"{\"Presentations\":[{\"prstId\":\"1\",\"cntId\":[1,2,3]}";
    [_webView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    _webView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _webView.layer.cornerRadius = 7;
    _webView.layer.masksToBounds = YES;
    _webView.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadPresentations : (NSMutableArray*) parsedObject {
    
    //_presentations = parsedObject;;
    _prstCntIds = [NSArray arrayWithArray:(NSMutableArray*)parsedObject];
    
//    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary* parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    _prstCntIds = [parsedObject objectForKey:@"SpecialtyPresentations"] ;
//    for (NSDictionary* cntId in [parsedObject objectForKey:@"SpecialtyPresentations"]) {
//        _prstCntIds = [cntId objectForKey:@"cntId"];
//    }
    _viewControllers = [[NSMutableDictionary alloc]initWithCapacity:10];
    _filePath = [DocumentsDirectory stringByAppendingPathComponent:[_prstCntIds objectAtIndex: self.counter]];
    
    //nslog(@"Path ---- %@",_filePath);
    [self play];
}

- (IBAction)previousButtonClicked:(id)sender {
    self.counter--;
    if (self.counter < 0) self.counter = 0;
    NSObject *object =  [_viewControllers valueForKey:_filePath]; //Check if previous one is a Player, if yes pause it
    
    _filePath = [DocumentsDirectory stringByAppendingPathComponent:[_prstCntIds objectAtIndex: self.counter]];
    
    if (object) {
        if ([object isKindOfClass:[MyMovieViewController class]]) {
            [(MyMovieViewController*) object pause];
        }
    }
    
    [self play];
}

- (IBAction)nextButtonClicked:(id)sender {
    self.counter++;
    if (self.counter >= _prstCntIds.count) self.counter = _prstCntIds.count - 1;
    NSObject *object =  [_viewControllers valueForKey:_filePath]; //Check if previous one is a Player, if yes pause it
    _filePath = [DocumentsDirectory stringByAppendingPathComponent:[_prstCntIds objectAtIndex: self.counter]];
    
    if (object) {
        if ([object isKindOfClass:[MyMovieViewController class]]) {
            [(MyMovieViewController*) object pause];
        }
    }
    
    [self play];
}

//This needs to be generalized so as to use in both ResourceViewer too.
//Best way is to create all views upfront and add them to UIScrollView and
//provide button to scroll up and down by one page (by one view)
- (void) play
{
    //nslog(@"count---%d--total--%d",counter,_prstCntIds.count);
    if (_prstCntIds.count ==1)
    {
        [self.leftBtn setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
        [self.rigthbtn setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
        self.leftBtn.userInteractionEnabled = NO;
        self.rigthbtn.userInteractionEnabled = NO;
    }
    else if (counter >0 && counter <(_prstCntIds.count - 1))
    {
        [self.leftBtn setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [self.rigthbtn setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
        self.leftBtn.userInteractionEnabled = YES;
        self.rigthbtn.userInteractionEnabled = YES;
    }
    else if (counter ==0 && counter <(_prstCntIds.count - 1))
    {
        [self.leftBtn setImage:[UIImage imageNamed:@"arrow_leftgrey.png"] forState:UIControlStateNormal];
        [self.rigthbtn setImage:[UIImage imageNamed:@"arrow-rigth.png"] forState:UIControlStateNormal];
        self.leftBtn.userInteractionEnabled = NO;
        self.rigthbtn.userInteractionEnabled = YES;
    }
    else if (counter >0 && counter ==(_prstCntIds.count - 1))
    {
        [self.leftBtn setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [self.rigthbtn setImage:[UIImage imageNamed:@"arrow-rigthgrey.png"] forState:UIControlStateNormal];
        self.leftBtn.userInteractionEnabled = YES;
        self.rigthbtn.userInteractionEnabled = NO;
    }
    //nslog(@"filePath: %@", _filePath);
    NSString* ext = [[_filePath pathExtension] lowercaseString];
    
    if ([ext isEqualToString:@"mp4"] ||
        [ext isEqualToString:@"m3u8"] ||
        [ext isEqualToString:@"m4v"]) {
        
        _webView.hidden = YES;
        
        NSObject *object =  [_viewControllers valueForKey:_filePath];
        if (object) {
            if ([object isKindOfClass:[MyMovieViewController class]]) {
                _myMovieViewController = (MyMovieViewController*)object;
            }
        } else {
            _myMovieViewController = [[MyMovieViewController alloc] initWithNibName:@"PlayerView" bundle:nil];
            [_myMovieViewController playMovieFile:[NSURL fileURLWithPath:_filePath]];
        }
        
        CGRect viewInsetRect = CGRectInset ([self.view bounds], 0, 20);
        [_myMovieViewController.view setFrame:viewInsetRect];
        [self.view addSubview:_myMovieViewController.view];
        [_viewControllers setObject:_myMovieViewController forKey:_filePath];
        
    } else if ([ext isEqualToString:@"html"] || [ext isEqualToString:@"pdf"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"]) {
        _webView.hidden = NO;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
        [_webView loadRequest:request];
        
        [self.view addSubview:_webView];
        [_viewControllers setObject:_webView forKey:_filePath];
    } else
    {
        NSRange rng = [ext rangeOfString:@"jpg"];
        NSRange rng1 = [ext rangeOfString:@"png"];

        if (rng.location != NSNotFound)
        {
            _webView.hidden = NO;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
            [_webView loadRequest:request];
            [self.view addSubview:_webView];
            [_viewControllers setObject:_webView forKey:_filePath];
        }
        else if (rng1.location != NSNotFound)
            {
                _webView.hidden = NO;
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
                [_webView loadRequest:request];
                [self.view addSubview:_webView];
                [_viewControllers setObject:_webView forKey:_filePath];
            }
        else
        {
            _webView.hidden = NO;
            //_filePath = [_filePath stringByAppendingString:@"/index.html"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
            [_webView loadRequest:request];
            [self.view addSubview:_webView];
            [_viewControllers setObject:_webView forKey:_filePath];

        }
        }
}

- (void) playByCntId : (int) cntId {
    
    
    //arrow_leftgrey  arrow-rigthgrey.png
    
    
   
    
    _filePath = [self filePathByCntId :cntId];
    if (_filePath != nil) {
        _filePath = [DocumentsDirectory stringByAppendingPathComponent:_filePath];
        [self play];
    } else {
        //nslog(@"Invalid File path");
    }
}

- (NSString*) filePathByCntId : (int) cntId
{
    NSManagedObjectContext* managedObjectContext = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    NSString* predicateString = [NSString stringWithFormat:@"%@ == %d", @"cntId", cntId];
    req.predicate = [NSPredicate predicateWithFormat:predicateString];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:req error:&error] mutableCopy];
    if (mutableFetchResults) {
        for (NSManagedObject* mo in mutableFetchResults) {
            NSString* filePath = [mo valueForKey:@"path"];
            if (filePath != nil && filePath.length > 0){
                return filePath;
            }
        }
    }
    return nil;
}

- (IBAction)closeButtonTouched:(id)sender
{
    [_myMovieViewController closeView];
    _webView = nil;
    [self unLoadDrawTool];
    [self dismissViewControllerAnimated:NO completion:nil];
}



-(IBAction)drawToolButtonClicked:(id)sender
{
    [self loadDrawTool];
    //[self showTransparentDrawTool];
    
}

- (void) loadDrawTool {
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    } else {
        _drawView = [[DrawVC alloc]initWithNibName:@"DrawView" bundle:nil] ;
        _drawView.view.backgroundColor = [UIColor clearColor];
        
//        CGRect viewFrame = self.view.frame;
//        float height = (viewFrame.size.height - 49 - 250 - 50);
//        CGSize newSize = CGSizeMake(viewFrame.size.width, height);
//        viewFrame.origin.y = 50;
//        viewFrame.size = newSize;
//        
//        _drawView.view.frame = viewFrame;
        _drawView.view.frame = CGRectMake(0, 40, 1024, 730);
        [self.view addSubview:_drawView.view];
        [self.view bringSubviewToFront:_drawView.view];
    }
}

- (void) unLoadDrawTool {
    if (_drawView) {
        [_drawView removeFromSuperView];
        _drawView = nil;
    }
}


@end
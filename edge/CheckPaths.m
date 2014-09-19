//
//  CheckPaths.m
//  edge
//
//  Created by Dheeraj Raju on 07/03/14.
//  Copyright (c) 2014 unknown. All rights reserved.
//

#import "CheckPaths.h"
#import <AVFoundation/AVFoundation.h>

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation CheckPaths

-(void) checkForPaths : (NSDictionary*) dictionry;
{
    if (dictionry != nil)
    {
        dict = [[NSMutableDictionary alloc] init];
        contents = [[NSMutableArray alloc] init];
        contentPath = [[NSString alloc] init];
        str = [[NSString alloc] init];
        htmlLoop = [[NSString alloc] init];
        
        [dict setObject:dictionry forKey:@"Body"];
        
        if ([[[dict objectForKey:@"Body"] objectForKey:@"Content"] count] !=0 )
        {
            for (int b= 0; b < [[[dict objectForKey:@"Body"] objectForKey:@"Content"] count]; b++)
            {
                str = nil;
                str = [[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"cntId"];

                if ([[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] count] != 0)
                {
                    if ([[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"path"])
                    {
                        html = 0;
                        
                        NSString* targetPath = [DocumentsDirectory stringByAppendingString:[[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"path"]];
                        BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
                        if (!success)
                        {
                            
                        }
                        else
                        {
                            checkType = 1;

                            contentPath = nil;
                            contentPath = [[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"path"];
                            if ([contentPath isEqualToString:@""])
                            {
                            }
                            else
                            {
                                if ([[targetPath pathExtension] isEqualToString:@"png"] || [[targetPath pathExtension] isEqualToString:@"jpg"]) {
                                    [self saveDictInArray];
                                }
                            
                            else if ([[targetPath pathExtension] isEqualToString:@"mp4"] || [[targetPath pathExtension] isEqualToString:@"mov"] || [[targetPath pathExtension] isEqualToString:@"m4v"])
                            {
                                NSURL *myURL = [NSURL fileURLWithPath:targetPath];
                                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:myURL options:nil];
                                
                                if (asset.playable)
                                {
                                    [self saveDictInArray];

                                }
                            }
                            
                            else if ([[targetPath pathExtension] isEqualToString:@"html"])
                            {
                                filePath = nil;
                                enumerator = nil;
                                
                                filePath = [targetPath stringByReplacingOccurrencesOfString:@"/index.html" withString:@""];
                                enumerator = [[NSFileManager defaultManager] enumeratorAtPath:filePath];
                                NSString *type= @"";
                                while ((filePath = [enumerator nextObject]) != nil){
                                    if (!([[filePath pathExtension] isEqualToString:type])){
                                        html = 1;
                                        htmlLoop = nil;
                                        htmlLoop = [[[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"path"] stringByReplacingOccurrencesOfString:@"index.html" withString:filePath];
                                        [self saveDictInArray];
                                    }
                                }
                            }
                                
                            else if ([[targetPath pathExtension] isEqualToString:@"pdf"])
                            {
                                    [self saveDictInArray];
                            }
                            else
                            {
                                [self saveDictInArray];
                            }
                        }
                    }
                }
                    
                
            
                    if ([[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"thumbnailImgPath"])
                    {
                        NSString* targetPath = [DocumentsDirectory stringByAppendingString:[[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"thumbnailImgPath"]];
                        
                        BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:targetPath];
                        if (!success)
                        {
                        }
                        else
                        {
                            checkType = 2;
                            contentPath = nil;
                            contentPath = [[[[dict objectForKey:@"Body"] objectForKey:@"Content"] objectAtIndex:b] objectForKey:@"thumbnailImgPath"];
                            
                            if ([contentPath  isEqual: @""])
                            {
                            }
                            else
                            {
                                [self saveDictInArray];
                            }
                        }
                    }
                
                }
            }
        }
        [[UpdateNotify SharedManager] setFilecontentdict:contents];
        //NSLog(@"contents %@",contents);
        //NSLog(@"contents count are %d",[contents count]);



    }
}
-(void) saveDictInArray
{
    NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] init];
    [contentDict removeAllObjects];
    [contentDict setObject:str forKey:@"cntId"];

    if (checkType == 1)
    {
        
        if (html == 1)
        {
            
            
            [contentDict setObject:htmlLoop forKey:@"path"];
        }
        else
        {
            [contentDict setObject:contentPath forKey:@"path"];
        }
        [contentDict setObject:@"MAIN" forKey:@"typeis"];
    }
    else
    {
        [contentDict setObject:@"THUMB" forKey:@"typeis"];
        [contentDict setObject:contentPath forKey:@"path"];
    }
    [contents addObject:contentDict];

}


@end

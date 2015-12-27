//
//  UploadTaskOperation.m
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/11/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import "UploadTaskOperation.h"
#import "DownloadTaskOperation.h"
#import "AppDelegate.h"

static const NSUInteger unitCount = 1;

@interface UploadTaskOperation ()
@property (nonatomic, strong, readwrite) NSProgress* progress;
@property (nonatomic, strong) NSProgress* parentProgress;
@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) BOOL executing;
@property (nonatomic, strong) NSOperationQueue* internalQueue;
@end

@implementation UploadTaskOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.progress = [NSProgress progressWithTotalUnitCount:unitCount];
        self.internalQueue = [[NSOperationQueue alloc]init];
    }
    return self;
}

/* simulate upload task using a download task */
- (void)start {
    
    NSLog(@"starting operation %@ with progress %@",self.name, self.progress);

    //create a random wait time to show progress in the UI
    NSUInteger seconds = arc4random_uniform(5);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSLog(@"waited for %lu seconds",(unsigned long)seconds);
        NSURLSession* session = [NSURLSession sharedSession];
        NSString* urlString = @"https://www.pexels.com/photo/night-fire-flame-fire-pit-21490/";
        NSURL *url = [NSURL URLWithString:urlString];

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        self.executing = YES;
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            self.executing = NO;

            //update progress on main queue
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                self.progress.completedUnitCount++;
            }];

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"operation %@ completed",self.name);

            self.finished = YES;
        }];
        
        [downloadTask resume];

    });
    

}
@end

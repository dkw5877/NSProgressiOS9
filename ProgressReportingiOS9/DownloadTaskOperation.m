//
//  DownloadTaskOperation.m
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/11/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import "DownloadTaskOperation.h"
#import "AppDelegate.h"
#import "UploadTaskOperation.h"

static const NSUInteger unitCount = 11; //1 for download operation, and 10 for upload operations

@interface DownloadTaskOperation ()
@property (nonatomic, strong) NSProgress* progress;
@property (nonatomic, strong) NSProgress* parentProgress;
@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) BOOL executing;
@property (nonatomic, strong) NSOperationQueue* internalQueue;
@end


@implementation DownloadTaskOperation

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

- (void)start {
    

    NSLog(@"starting operation %@ with progress %@",self.name, self.progress);
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSString* urlString = @"https://www.dropbox.com/s/uxlu4qpxgtjcwh8/257H.jpg?dl=1"; //large file
    NSURL *url = [NSURL URLWithString:urlString];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.executing = YES;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        self.executing = NO;
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        //update progress on main queue
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.progress.completedUnitCount++;
        }];

        [self uploadData];

        NSLog(@"operation %@ completed",self.name);
        self.finished = YES;
    }];
    
    [downloadTask resume];
}

- (void)uploadData {
    //lets assume the frist task takes 70% of the time and the second 30%
    NSInteger firstTaskSteps = 7;
    NSInteger secondTaskSteps = 3;

    //create the first task, add as child
    UploadTaskOperation* upload1 = [[UploadTaskOperation alloc]init];
    upload1.name = [NSString stringWithFormat:@"upload1 task for %@",self.name];
    [self.progress addChild:upload1.progress withPendingUnitCount:firstTaskSteps];

    //creaet the second task, add as child
    UploadTaskOperation* upload2 = [[UploadTaskOperation alloc]init];
    upload2.name = [NSString stringWithFormat:@"upload2 task for %@",self.name];
    [self.progress addChild:upload2.progress withPendingUnitCount:secondTaskSteps];

    [self.internalQueue addOperations:@[upload1, upload2] waitUntilFinished:NO];

}
@end

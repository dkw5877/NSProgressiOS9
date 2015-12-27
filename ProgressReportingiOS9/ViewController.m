//
//  ViewController.m
//  ProgressReportingiOS9
//
//  Created by user on 12/12/15.
//  Copyright © 2015 someCompanyNameHere. All rights reserved.
//

#import "ViewController.h"
#import "ParentProgressOperation.h"
#import "DownloadTaskOperation.h"


static void *ProgressObserverContext = &ProgressObserverContext;

@interface ViewController ()
@property (nonatomic, strong) IBOutlet UIProgressView* progressBar;
@property (nonatomic, strong) IBOutlet UILabel* progressLabel;
@property (nonatomic, strong) IBOutlet UILabel* progressDescriptionLabel;
@property (nonatomic, strong) NSProgress* progress;
@property (nonatomic, strong) NSOperationQueue* progressQueue;
@property (nonatomic, strong) NSString* progressKind;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)start:(id)sender {
    [self launchChildOperations];
}

- (IBAction)toggleProgressType:(id)sender {

    if (!self.progress.kind) {
        self.progressKind = NSProgressKindFile;
        return;
    }

    self.progressKind = nil;
}


- (void)launchChildOperations {

    NSUInteger workUnits = 3;
    //create parent progress
    self.progress = [NSProgress progressWithTotalUnitCount:workUnits];
    self.progress.kind = self.progressKind;

    //setup user info dictionary if we set progress kind
    if (self.progress.kind) {
        [self.progress setUserInfoObject:NSProgressFileOperationKindDownloading forKey:NSProgressFileOperationKindKey];
    }

    //KVO to observe progess
    [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionInitial context:ProgressObserverContext];

    //create a queue for the operations
    self.progressQueue = [[NSOperationQueue alloc]init];
    self.progressQueue.name = @"Progress Queue";

    /* create several download operations, each operation is one unit of work */
    for (NSUInteger i = 0; i < workUnits; i++) {
        DownloadTaskOperation* op = [[DownloadTaskOperation alloc]init];
        op.name = [NSString stringWithFormat:@"download task %lu",(unsigned long)i];
        [self.progress addChild:op.progress withPendingUnitCount:1];
        [self.progressQueue addOperation:op];
    }
}

/* use KVO to observe the top most partent progess which is updated by the child progress objects */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {

    if (context == ProgressObserverContext) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSProgress *progress = object;
            self.progressBar.progress = progress.fractionCompleted;
            self.progressLabel.text = progress.localizedDescription;
            self.progressDescriptionLabel.text = progress.localizedAdditionalDescription;
        }];
    } else {
        // Always call super, incase it uses KVO also
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [_progress removeObserver:self forKeyPath:@"fractionCompleted" context:ProgressObserverContext];
}

@end

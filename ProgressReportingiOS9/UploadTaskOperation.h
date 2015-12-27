//
//  UploadTaskOperation.h
//  ProgressReporting
//
//  Created by Dennis Walsh on 12/11/15.
//  Copyright (c) 2015 Dennis Walsh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadTaskOperation : NSOperation <NSProgressReporting>
@property (atomic, strong, readonly) NSProgress* progress;

@end

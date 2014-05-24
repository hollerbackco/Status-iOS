//
//  STAppManager.h
//  Status
//
//  Created by Joe Nguyen on 21/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNAppManager.h"

@interface STAppManager : JNAppManager

+ (void)updateAppVersion;

+ (void)checkForUpdates;

@end

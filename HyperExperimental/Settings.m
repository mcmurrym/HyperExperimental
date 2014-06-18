//
//  Settings.m
//  welbe
//
//  Created by Tim Shadel on 9/24/13.
//  Copyright (c) 2013 O.C. Tanner Corporation. All rights reserved.
//

#import "Settings.h"
#import <SharedInstanceGCD/SharedInstanceGCD.h>

@interface Settings ()

@end

@implementation Settings

SHARED_INSTANCE_GCD

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    return self;
}


- (void)loadSettings {
    [NSUserDefaults resetStandardUserDefaults];
    [self loadLocalSettings];
}


- (void)loadLocalSettings {
    [self loadHardcodedDefaults];
    [self loadBundleDefaults];
}


- (NSDictionary *)hardcodedDefaults {
    return @ {
    };
}


- (void)loadHardcodedDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self hardcodedDefaults]];
}


- (void)loadBundleDefaults {
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *bundleDefaults = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[bundle URLForResource:@"settings" withExtension:@"json"]] options:0 error:nil];
    if (bundleDefaults) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:bundleDefaults];
    }
}

@end

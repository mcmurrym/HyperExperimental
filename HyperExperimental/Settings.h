//
//  Settings.h
//  welbe
//
//  Created by Tim Shadel on 9/24/13.
//  Copyright (c) 2013 O.C. Tanner Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (instancetype)sharedInstance;

- (void)loadSettings;


@end

//
//  HyperIndexedTree.h
//  HyperExperimental
//
//  Created by Matt McMurry on 6/30/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HyperIndexedTree : NSObject

+ (instancetype)sharedInstance;

- (id)indexedObjectWithKey:(NSString *)hrefKey;
- (void)addItemToIndex:(id)obj key:(NSString *)hrefKey;

@end

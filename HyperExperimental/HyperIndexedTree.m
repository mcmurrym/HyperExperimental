//
//  HyperIndexedTree.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/30/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "HyperIndexedTree.h"
#import <SharedInstanceGCD/SharedInstanceGCD.h>
#import <MMWeakValue/MMWeakValue.h>

@interface HyperIndexedTree ()

@property (nonatomic, strong) NSMutableDictionary *indexedItems;

@end

@implementation HyperIndexedTree

SHARED_INSTANCE_GCD

- (id)init {
    self = [super init];
    
    self.indexedItems = [@{} mutableCopy];
    
    return self;
}

#pragma mark - manage indexed keys
- (void)indexItem:(id)obj forKey:(NSString *)hrefKey {
    
    if (!self.indexedItems) {
        self.indexedItems = [NSMutableDictionary dictionary];
    }
    
    self.indexedItems[hrefKey] = [MMWeakValue weakValueWithObject:obj];
}

- (id)indexedObjectWithKey:(NSString *)hrefKey {
    
    if (!self.indexedItems) {
        self.indexedItems = [NSMutableDictionary dictionary];
    }
    
    id returnValue = nil;
    
    MMWeakValue *weakValue = self.indexedItems[hrefKey];
    
    if (!weakValue) {
        NSURL *url = [NSURL URLWithString:hrefKey];
        NSString *relpath = [url relativePath];
        
        weakValue = self.indexedItems[relpath];
        
        if (weakValue) {
            hrefKey = relpath;
        }
    }
    
    if (weakValue) {
        if (weakValue.object) {
            returnValue = weakValue.object;
        } else {
            [self.indexedItems removeObjectForKey:hrefKey];
        }
    }
    
    return returnValue;
}

/**
 *  This will remove niled MMWeakValues. Just not sure on when to call it right now.
 */
- (void)clean {
    NSMutableArray *keysToRemove = [NSMutableArray array];
    [self.indexedItems enumerateKeysAndObjectsUsingBlock:^(id key, MMWeakValue *obj, BOOL *stop) {
        if (!obj.object) {
            [keysToRemove addObject:key];
        }
    }];
    
    [self.indexedItems removeObjectsForKeys:keysToRemove];
}

@end

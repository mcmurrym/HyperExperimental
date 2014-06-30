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

@implementation HyperIndexedTree

SHARED_INSTANCE_GCD

#pragma mark - manage indexed keys

static NSMutableDictionary *indexedItems;

- (void)addItemToIndex:(id)obj key:(NSString *)hrefKey {
    
    if (!indexedItems) {
        indexedItems = [NSMutableDictionary dictionary];
    }
    
    indexedItems[hrefKey] = [MMWeakValue weakValueWithObject:obj];
}

- (id)indexedObjectWithKey:(NSString *)hrefKey {
    
    if (!indexedItems) {
        indexedItems = [NSMutableDictionary dictionary];
    }
    
    id returnValue = nil;
    
    MMWeakValue *weakValue = indexedItems[hrefKey];
    
    if (!weakValue) {
        NSURL *url = [NSURL URLWithString:hrefKey];
        NSString *relpath = [url relativePath];
        
        weakValue = indexedItems[relpath];
        
        if (weakValue) {
            hrefKey = relpath;
        }
    }
    
    if (weakValue) {
        if (weakValue.object) {
            returnValue = weakValue.object;
        } else {
            [indexedItems removeObjectForKey:hrefKey];
        }
    }
    
    return returnValue;
}

@end

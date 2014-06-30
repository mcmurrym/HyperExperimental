//
//  NSMutableArray+Hyper.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/30/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "NSMutableArray+Hyper.h"
#import "HyperIndexedTree.h"

@implementation NSMutableArray (Hyper)

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    id obj = [super objectAtIndexedSubscript:idx];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *href = obj[HyperDictionaryKeyHref];
        
        if (href) {
            id indexedObject = [[HyperIndexedTree sharedInstance] indexedObjectWithKey:href];
            
            if (indexedObject) {
                obj = indexedObject;
            } else {
                [[HyperIndexedTree sharedInstance] addItemToIndex:obj key:href];
            }
        }
    }
    
    return obj;
}

@end

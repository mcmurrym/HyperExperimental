//
//  Hyper.m
//  HyperExperimental
//
//  Created by Matt McMurry on 7/1/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "Hyper.h"
#import "NSMutableDictionary+Hyper.h"
#import "HyperIndexedTree.h"

@interface Hyper ()

@property (nonatomic, strong) NSMutableDictionary *hyperObject;

@end

@implementation Hyper

+ (NSMutableDictionary *)dictionaryWithRootHref:(NSString *)rootHref {
    
    Hyper *hyper = [Hyper new];
    hyper.hyperObject = [NSMutableDictionary dictionaryWithRootHref:rootHref];
    
    return (NSMutableDictionary *)hyper;
}


- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.hyperObject;
}


- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    id obj = [self.hyperObject objectForKeyedSubscript:key];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *href = obj[HyperDictionaryKeyHref];
        
        if (href) {
            id indexedObject = [[HyperIndexedTree sharedInstance] indexedObjectWithKey:href];
            
            if (indexedObject) {
                obj = indexedObject;
            } else {
                [[HyperIndexedTree sharedInstance] indexItem:obj forKey:href];
            }
            
            Hyper *hyper = [Hyper new];
            hyper.hyperObject = obj;
            obj = hyper;
        }
    }
    
    return obj;
}


- (BOOL)isKindOfClass:(Class)aClass {
    return [self.hyperObject isKindOfClass:aClass];
}

- (NSString *)description {
    return [self.hyperObject description];
}

@end

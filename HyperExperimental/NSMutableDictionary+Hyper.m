//
//  NSMutableDictionary+Hyper.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/17/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "NSMutableDictionary+Hyper.h"
#import "Network.h"
#import "HyperIndexedTree.h"

NSString * const HyperDictionaryKeyHref = @"href";
NSString * const HyperDictionaryKeyURL = @"url";

@implementation NSMutableDictionary (Hyper)


+ (instancetype)dictionaryWithRootHref:(NSString *)href {
    NSMutableDictionary *dict = [@{HyperDictionaryKeyHref: href} mutableCopy];
    [[HyperIndexedTree sharedInstance] indexItem:dict forKey:href];
    return dict;
}

- (void)GET:(GETCompletionBlock)completion {
    
    NSString *href = self[HyperDictionaryKeyHref];
    if (!href) {
        if (completion) {
            completion(self, YES, nil);
        }
        return;
    }
    
    GETCompletionBlock block;
    if (completion) {
        block = [completion copy];
    }
    
    [self runCache:href completion:block];
}


- (void)runCache:(NSString *)href completion:(GETCompletionBlock)completion {
    [[Network cache] GET:href
              parameters:nil
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (![responseObject isEqualToDictionary:self]) {
                         [self addEntriesFromDictionary:responseObject];
                     }
                     
                     //order? I chose network first so that it can start
                     //downloading and the completion block can take as
                     //long as it wants to.
                     
                     //run network
                     [self runNetwork:href completion:completion];
                     
                     //run block
                     if (completion) {
                         completion(self, YES, nil);
                     }
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     [self runNetwork:href completion:completion];
                 }];
}


- (void)runNetwork:(NSString *)href completion:(GETCompletionBlock)completion {
    [[Network api] GET:href
            parameters:nil
               success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                   if (![responseObject isEqualToDictionary:self]) {
                       [self addEntriesFromDictionary:responseObject];
                   }
                   
                   if (completion) {
                       completion(self, YES, nil);
                   }
               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                   if (completion) {
                       completion(self, NO, error);
                   }
               }];
}


- (BOOL)isExternalResource {
    NSArray *allKeys = [self allKeys];
    
    if ([allKeys count] == 1 && [[allKeys firstObject] isEqual:HyperDictionaryKeyURL]) {
        return YES;
    } else {
        return NO;
    }
}


- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    id obj = [super objectForKeyedSubscript:key];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *href = obj[HyperDictionaryKeyHref];
        
        if (href) {
            id indexedObject = [[HyperIndexedTree sharedInstance] indexedObjectWithKey:href];
            
            if (indexedObject) {
                obj = indexedObject;
            } else {
                [[HyperIndexedTree sharedInstance] indexItem:obj forKey:href];
            }
        }
    }
    
    return obj;
}


@end

//
//  NSMutableDictionary+Hyper.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/17/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "NSMutableDictionary+Hyper.h"
#import "Network.h"

NSString * const HyperDictionaryKeyHref = @"href";

@implementation NSMutableDictionary (Hyper)

+ (instancetype)dictionaryWithRootHref:(NSString *)rootHref {
    NSMutableDictionary *dict = [@{HyperDictionaryKeyHref: rootHref} mutableCopy];
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
    
    [[Network api] GET:href
            parameters:nil
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   NSLog(@"response %@", responseObject);
                   
                   [self addEntriesFromDictionary:responseObject];
                   
                   if (block) {
                       block(self, YES, nil);
                   }
                   
               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                   NSLog(@"response error %@", error);
                   if (block) {
                       block(self, NO, error);
                   }
               }];
}

@end

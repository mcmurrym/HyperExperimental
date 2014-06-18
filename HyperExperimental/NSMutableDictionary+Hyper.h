//
//  NSMutableDictionary+Hyper.h
//  HyperExperimental
//
//  Created by Matt McMurry on 6/17/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HyperDictionaryKeyHref;

typedef void(^GETCompletionBlock)(NSMutableDictionary *dictionary, BOOL succeded, NSError *error);

@interface NSMutableDictionary (Hyper)

+ (instancetype)dictionaryWithRootHref:(NSString *)rootHref;
- (void)GET:(GETCompletionBlock)completion;

@end

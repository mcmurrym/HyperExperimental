//
//  NSMutableDictionary+Hyper.h
//  HyperExperimental
//
//  Created by Matt McMurry on 6/17/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HyperDictionaryKeyHref;
extern NSString * const HyperDictionaryKeyURL;

typedef void(^GETCompletionBlock)(NSMutableDictionary *dictionary, BOOL succeded, NSError *error);

@interface NSMutableDictionary (Hyper)

+ (instancetype)dictionaryWithRootHref:(NSString *)rootHref;

/**
 *  GET uses the defined href on the dictionary if it is defined to update the dictionary with the latest
 *  information. If the dictionary does not have an href the completion block will resolve immediately.
 *  The supplied block may run multiple times 2 at the most and 1 at the very least. 2 runs means the cache resolved
 *  with data and the network to update the object succeeded or failed. 1 run of the block means their was no previous
 *  cache and the network call to update the object succeeded or failed.
 *
 *  @param completion A block to call when completions occur (when data is got)
 */
- (void)GET:(GETCompletionBlock)completion;
- (BOOL)isExternalResource;

@end

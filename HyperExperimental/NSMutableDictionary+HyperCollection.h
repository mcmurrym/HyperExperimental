//
//  NSMutableDictionary+HyperCollection.h
//  HyperExperimental
//
//  Created by Matt McMurry on 6/18/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HyperCollection.h"

extern NSString * const HyperDictionaryKeyCollection;
extern NSString * const HyperDictionaryKeyCollectionNext;
extern NSString * const HyperDictionaryKeyCollectionPrevious;

typedef void(^GETNextCompletionBlock)(NSMutableDictionary *dictionary, NSUInteger addedCount, BOOL succeded, NSError *error);

@interface NSMutableDictionary (HyperCollection) <HyperCollection>

- (BOOL)isCollection;

- (void)GETNext:(GETNextCompletionBlock)completion;

@end

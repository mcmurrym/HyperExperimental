//
//  Hyper+Collection.h
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

typedef void(^GETNextCompletionBlock)(Hyper *hyper, NSUInteger addedCount, BOOL succeded, NSError *error);

@interface Hyper (Collection) <HyperCollection>

- (BOOL)isCollection;

- (void)GETNext:(GETNextCompletionBlock)completion;

@end

//
//  Hyper+Collection.m
//  HyperExperimental
//
//  Created by Matt McMurry on 6/18/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "Hyper+Collection.h"
#import "Network.h"

NSString * const HyperDictionaryKeyCollection = @"collection";
NSString * const HyperDictionaryKeyCollectionNext = @"next";
NSString * const HyperDictionaryKeyCollectionLastNext = @"org.hyper.json.last_next";
NSString * const HyperDictionaryKeyCollectionPrevious = @"prev";


@implementation Hyper (Collection)

- (NSMutableArray *)collection {
    return self[HyperDictionaryKeyCollection];
}

- (NSString *)next {
    return self[HyperDictionaryKeyCollectionNext][HyperDictionaryKeyHref];
}

- (NSString *)previous {
    return self[HyperDictionaryKeyCollectionPrevious][HyperDictionaryKeyHref];
}

- (BOOL)isCollection {
    return (self[HyperDictionaryKeyCollection] != nil);
}


- (void)GETNext:(GETNextCompletionBlock)completion {
    NSString *href = [self next];
    if (!href) {
        if (completion) {
            completion(self, 0, YES, nil);
        }
        return;
    } else {
        self[HyperDictionaryKeyCollectionLastNext] = href;
        [self removeObjectForKey:HyperDictionaryKeyCollectionNext];
    }
    
    GETNextCompletionBlock block;
    if (completion) {
        block = [completion copy];
    }
    
    [[Network api] GET:href
            parameters:nil
               success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                   [self removeObjectForKey:HyperDictionaryKeyCollectionLastNext];
                   if ([responseObject[HyperDictionaryKeyCollection] count] > 0) {
                       NSMutableArray *lastCollection = [self[HyperDictionaryKeyCollection] mutableCopy];
                       NSMutableArray *newCollection = responseObject[HyperDictionaryKeyCollection];
                       
                       [lastCollection addObjectsFromArray:newCollection];
                       
                       [self addEntriesFromDictionary:responseObject];
                       
                       self[HyperDictionaryKeyCollection] = lastCollection;
                       
                       if (block) {
                           block(self, [newCollection count], YES, nil);
                       }
                   } else {
                       if (block) {
                           block(self, 0, YES, nil);
                       }
                   }
               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                   
                   self[HyperDictionaryKeyCollectionNext] = self[HyperDictionaryKeyCollectionLastNext];
                   [self removeObjectForKey:HyperDictionaryKeyCollectionLastNext];
                   
                   if (block) {
                       block(self, 0, NO, error);
                   }
               }];
}

@end

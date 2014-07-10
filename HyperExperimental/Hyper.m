//
//  Hyper.m
//  HyperExperimental
//
//  Created by Matt McMurry on 7/1/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "Hyper.h"
#import "HyperIndexedTree.h"
#import "Network.h"
#import "Hyperray.h"

NSString * const HyperDictionaryKeyHref = @"href";
NSString * const HyperDictionaryKeyURL = @"url";


@interface Hyper ()

@property (nonatomic, strong) NSMutableDictionary *hyperObject;

@end

@implementation Hyper

#pragma mark - Subclassing methods to override
- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)count {
    self = [super init];
    
    self.hyperObject = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:count];
    
    return self;
}

- (NSUInteger)count {
    return self.hyperObject.count;
}


- (id)objectForKey:(id)aKey {
    id obj = [self.hyperObject objectForKey:aKey];
    
    return [Hyper getHyperObjectIfPossible:obj];
}


- (NSEnumerator *)keyEnumerator {
    return [self.hyperObject keyEnumerator];
}

#pragma mark - Custom methods
+ (instancetype)dictionaryWithRootHref:(NSString *)href {
    Hyper *hyper = [Hyper new];
    NSMutableDictionary *dict = [@{HyperDictionaryKeyHref: href} mutableCopy];
    hyper.hyperObject = dict;
    [[HyperIndexedTree sharedInstance] indexItem:hyper forKey:href];
    return hyper;
}


- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    id obj = [self.hyperObject objectForKeyedSubscript:key];
    
    obj = [Hyper getHyperObjectIfPossible:obj];
    
    return obj;
}


+ (id)getHyperObjectIfPossible:(id)obj {
    
    id returnObject = obj;
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *href = obj[HyperDictionaryKeyHref];
        
        if (href) {
            id indexedObject = [[HyperIndexedTree sharedInstance] indexedObjectWithKey:href];
            
            if (indexedObject) {
                returnObject = indexedObject;
            } else {
                
                Hyper *hyper = [Hyper new];
                hyper.hyperObject = obj;
                returnObject = hyper;
                
                [[HyperIndexedTree sharedInstance] indexItem:returnObject forKey:href];
            }
            
        } else {
            Hyper *hyper = [Hyper new];
            hyper.hyperObject = obj;
            returnObject = hyper;
        }
        
    } else if ([obj isKindOfClass:[NSArray class]] && ![obj isKindOfClass:[Hyperray class]]) {
        NSArray *array = (NSArray *)obj;
        
        if ([array isHyperray] ) {
            Hyperray *hyperray = [Hyperray hyperrayWithArray:array];
            returnObject = hyperray;
        }
    }
    
    return returnObject;
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
                     if (![responseObject isEqualToDictionary:self.hyperObject]) {
                         [self.hyperObject addEntriesFromDictionary:responseObject];
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
                   if (![responseObject isEqualToDictionary:self.hyperObject]) {
                       [self.hyperObject addEntriesFromDictionary:responseObject];
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

@end

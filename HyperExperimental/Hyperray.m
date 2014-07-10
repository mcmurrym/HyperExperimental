//
//  Hyperray.m
//  HyperExperimental
//
//  Created by Matt McMurry on 7/10/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "Hyperray.h"
#import "HyperIndexedTree.h"

@interface Hyperray ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation Hyperray

#pragma mark - Subclassing methods to override
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count {
    self = [super init];
    
    self.array = [[NSMutableArray alloc] initWithObjects:objects count:count];
    
    return self;
}

- (NSUInteger)count {
    return self.array.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    id obj = [self.array objectAtIndex:index];
    return [Hyper getHyperObjectIfPossible:obj];
}

#pragma mark - Custom methods
+ (instancetype)hyperrayWithArray:(NSArray *)array {
    Hyperray *hyperray = [Hyperray new];
    hyperray.array = [array mutableCopy];
    return hyperray;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    id obj = [self.array objectAtIndexedSubscript:idx];
    return [Hyper getHyperObjectIfPossible:obj];
}

@end

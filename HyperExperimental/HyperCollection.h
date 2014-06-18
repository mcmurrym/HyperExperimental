//
//  HyperCollection.h
//  HyperExperimental
//
//  Created by Matt McMurry on 6/18/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HyperCollection <NSObject>

- (NSMutableArray *)collection;
- (NSString *)next;
- (NSString *)previous;

@end

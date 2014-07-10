//
//  NSArray+HyperrayValidate.m
//  HyperExperimental
//
//  Created by Matt McMurry on 7/10/14.
//  Copyright (c) 2014 OC Tanner. All rights reserved.
//

#import "NSArray+HyperrayValidate.h"
#import <objc/runtime.h>

static void *checkedHyper;
static void *isHyper;

@interface NSArray ()

@property (nonatomic, assign) BOOL hasCheckedForHyperray;
@property (nonatomic, assign) BOOL isValidHyperray;

@end

@implementation NSArray (HyperrayValidate)

- (BOOL)isHyperray {
    
    if (self.hasCheckedForHyperray) {
        return self.isValidHyperray;
    } else {
    
        __block BOOL hyperray = YES;
    
        [self enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[NSDictionary class]]) {
                hyperray = NO;
                *stop = YES;
                return;
            }
            
            if (!obj[HyperDictionaryKeyHref]) {
                hyperray = NO;
                *stop = YES;
                return;
            }
        }];
        
        
        self.hasCheckedForHyperray = YES;
        self.isValidHyperray = hyperray;
        
        return hyperray;
    }
}

- (void)setHasCheckedForHyperray:(BOOL)checked {
    objc_setAssociatedObject(self, &checkedHyper, @(checked), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasCheckedForHyperray {
    NSNumber *checked = objc_getAssociatedObject(self, &checkedHyper);
    
    BOOL checkedBOOL = NO;
    
    if (checked) {
        checkedBOOL = [checked boolValue];
    }
    
    return checkedBOOL;
}

- (void)setIsValidHyperray:(BOOL)valid {
    objc_setAssociatedObject(self, &isHyper, @(valid), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isValidHyperray {
    NSNumber *valid = objc_getAssociatedObject(self, &isHyper);
    
    BOOL validBool = NO;
    
    if (valid) {
        validBool = [valid boolValue];
    }
    
    return validBool;
}

@end

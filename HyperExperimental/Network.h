//
//  Network.h
//  welbe
//
//  Created by Tim Shadel on 9/24/13.
//  Copyright (c) 2013 O.C. Tanner Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface Network : NSObject

+ (instancetype)sharedInstance;
+ (AFHTTPSessionManager *)api;

@end

//
//  JSONResponseSerializerWithData.h
//  welbe
//
//  Created by Tim Shadel on 11/1/13.
//  Copyright (c) 2013 O.C. Tanner Corporation. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end

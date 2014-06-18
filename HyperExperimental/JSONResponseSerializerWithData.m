//
//  JSONResponseSerializerWithData.m
//  welbe
//
//  Created by Tim Shadel on 11/1/13.
//  Copyright (c) 2013 O.C. Tanner Corporation. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSMutableSet *set = [self.acceptableContentTypes mutableCopy];
    [set addObject:@"application/hyper+json"];
    self.acceptableContentTypes = set;
    self.readingOptions = self.readingOptions | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers;
    
    return self;
}


- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    id JSONObject = [super responseObjectForResponse:response data:data error:error]; // may mutate `error`
    
    //##OBJCLEAN_SKIP##
    if (*error) {
        //##OBJCLEAN_ENDSKIP##
        NSMutableDictionary *mutableUserInfo = [(*error).userInfo mutableCopy];
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [mutableUserInfo setObject:responseBody forKey:@"responseBody"];
        if (self.acceptableContentTypes && [self.acceptableContentTypes containsObject:[response MIMEType]] && responseBody && ![responseBody isEqualToString:@" "]) {
            // Workaround for a bug in NSJSONSerialization when Unicode character escape codes are used instead of the actual character
            // See http://stackoverflow.com/a/12843465/157142
            NSData *data = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
            
            if (data) {
                if ([data length] > 0) {
                    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:error];
                    if (responseObject) {
                        [mutableUserInfo setObject:responseObject forKey:@"responseObject"];
                    }
                }
            }
        }
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:[mutableUserInfo copy]];
        (*error) = newError;
    }
    
    return JSONObject;
}

@end

//
//  Network.m
//  welbe
//
//  Created by Tim Shadel on 9/24/13.
//  Copyright (c) 2013 O.C. Tanner Corporation. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"
#import <SharedInstanceGCD/SharedInstanceGCD.h>
#import "Network.h"

@interface Network ()

@property (nonatomic, strong) AFHTTPSessionManager *apiSession;
@property (nonatomic, strong) AFHTTPSessionManager *apiCacheSession;
@property (nonatomic, strong) NSURLCache *cache;
@property (nonatomic, strong) NSURL *apiURL;
@property (nonatomic, strong) void (^reachabilityStatusChanged)(AFNetworkReachabilityStatus status);

@end

@implementation Network {
    BOOL _checkingConnection;
    BOOL _connectionStatusUnknown;
}


SHARED_INSTANCE_GCD

+ (AFHTTPSessionManager *)api {
    return [Network sharedInstance].apiSession;
}


+ (AFHTTPSessionManager *)cache {
    return [Network sharedInstance].apiCacheSession;
}


- (id)init {
    if (!(self = [super init])) {
        return nil;
    }

    self.apiURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"API.href"]];
    if (!self.apiURL) {
        NSLog(@"API.href has no value in user defaults: %@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
        return nil;
    }

    self.cache = [[NSURLCache alloc] initWithMemoryCapacity:(16 * 1024) diskCapacity:(256 * 1024 * 1024) diskPath:@"/NetworkCache"];

    // Reachability isn't reliable until you've attempted a request; use it only as a way to react to errors.
    _checkingConnection = NO;
    _connectionStatusUnknown = YES;
    [self setupOnlineSession];
    [self setupCacheSession];
    
    return self;
}


// Used with testing
- (void)hijackSessionWithProtocolClasses:(NSArray *)protocolClasses {
    NSURLSessionConfiguration *hijackedConfig = self.apiSession.session.configuration;
    hijackedConfig.protocolClasses = protocolClasses;
    [self.apiSession invalidateSessionCancelingTasks:YES];
    self.apiSession = [[AFHTTPSessionManager alloc] initWithBaseURL:self.apiURL sessionConfiguration:hijackedConfig];
}


- (void)setupOnlineSession {
    [self.apiSession invalidateSessionCancelingTasks:NO];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.URLCache = self.cache;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    self.apiSession = [[AFHTTPSessionManager alloc] initWithBaseURL:self.apiURL sessionConfiguration:configuration];

    __weak __typeof(self)weakSelf = self;
    self.reachabilityStatusChanged = ^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf; if (!strongSelf) {
            return;
        }
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [strongSelf setupOfflineSession];
        }
    };
    [self.apiSession.reachabilityManager setReachabilityStatusChangeBlock:self.reachabilityStatusChanged];
    [self.apiSession.reachabilityManager startMonitoring];
    NSLog(@"\nONLINE\n");

    [self postSetupConfig];
    
    self.apiSession.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;

    [self checkAPIConnectivitySynchronously];
}


- (void)setupOfflineSession {
    [self.apiSession invalidateSessionCancelingTasks:YES];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.URLCache = self.cache;
    configuration.requestCachePolicy = NSURLRequestReturnCacheDataDontLoad;
    self.apiSession = [[AFHTTPSessionManager alloc] initWithBaseURL:self.apiURL sessionConfiguration:configuration];

    __weak __typeof(self)weakSelf = self;
    self.reachabilityStatusChanged = ^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf; if (!strongSelf) {
            return;
        }
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            [strongSelf setupOnlineSession];
        }
    };
    [self.apiSession.reachabilityManager setReachabilityStatusChangeBlock:self.reachabilityStatusChanged];
    [self.apiSession.reachabilityManager startMonitoring];
    NSLog(@"\nOFFLINE\n");

    [self postSetupConfig];
    
    self.apiSession.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
}


- (void)setupCacheSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.URLCache = self.cache;
    configuration.requestCachePolicy = NSURLRequestReturnCacheDataDontLoad;
    self.apiCacheSession = [[AFHTTPSessionManager alloc] initWithBaseURL:self.apiURL sessionConfiguration:configuration];
    [self postSetupCacheConfig];
    
    self.apiCacheSession.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
}


- (void)postSetupConfig {
    self.apiSession.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    [self.apiSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.apiSession.responseSerializer = [[JSONResponseSerializerWithData alloc] init];
}


- (void)postSetupCacheConfig {
    self.apiCacheSession.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    [self.apiCacheSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.apiCacheSession.responseSerializer = [[JSONResponseSerializerWithData alloc] init];
}


//- (void)updateUserSettings {
//    WBAccountController *account = [WBAccountController sharedInstance];
//    if (account.isLoggedIn) {
//        [self.apiSession.requestSerializer setValue:account.currentAuthToken forHTTPHeaderField:@"X-Auth-Token"];
//    }
//}


- (void)checkAPIConnectivitySynchronously {
    if (_connectionStatusUnknown && !_checkingConnection) {
        _checkingConnection = YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self.apiSession GET:@"availability" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"Test API call succeeded");
            _checkingConnection = NO;
            _connectionStatusUnknown = NO;
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Test API call failed");
            _checkingConnection = NO;
            _connectionStatusUnknown = NO;
            dispatch_semaphore_signal(semaphore);
        }];

        NSDate *asyncTimeout = [NSDate dateWithTimeIntervalSinceNow:1.5];
        BOOL done = NO;
        while (!done && dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            done = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncTimeout];
            if (done) {
                _checkingConnection = NO;
            }
        }
    }
}

@end

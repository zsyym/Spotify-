//
//  SCNetworkClient.m
//  Spotify
//
//  Created by MacBook Air on 2026/11/25.
//

#import "SCNetworkClient.h"

#import <AFNetworking/AFNetworking.h>
NS_ASSUME_NONNULL_BEGIN

static NSString* const SCAPIBaseURLString = @"https://msapi.awup.cn/";
static NSTimeInterval const SCRequestTimeout = 15.0;

@implementation SCNetworkClient

#pragma mark - Public Methods

+(AFHTTPSessionManager *)sharedSessionManager {
    static AFHTTPSessionManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL* baseURL = [NSURL URLWithString:SCAPIBaseURLString];
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies = NO;
        configuration.HTTPCookieStorage = nil;
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
        AFHTTPRequestSerializer* requestSerializer = [AFHTTPRequestSerializer serializer];
        requestSerializer.timeoutInterval = SCRequestTimeout;
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    return manager;
}

@end

NS_ASSUME_NONNULL_END

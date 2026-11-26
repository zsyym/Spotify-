//
//  SCNetworkClient.m
//  Spotify
//
//  Created by MacBook Air on 2026/11/25.
//

#import "SCNetworkClient.h"

#import <AFNetworking/AFNetworking.h>
NS_ASSUME_NONNULL_BEGIN

static NSString *const SCAPIBaseURLString = @"https://msapi.awup.cn/";
static NSTimeInterval const SCRequestTimeout = 15.0;

@interface SCNetworkClient ()

+ (AFHTTPSessionManager *)sharedSessionManager;
+ (nullable NSHTTPURLResponse *)HTTPResponseForTask:(nullable NSURLSessionDataTask *)task;

@end

@implementation SCNetworkClient

#pragma mark - Public Methods
+ (nullable NSURLSessionTask *)GET:(NSString *)path
                        parameters:(nullable NSDictionary<NSString *, id> *)parameters
                           success:(SCNetworkSuccessBlock)success
                           failure:(SCNetworkFailureBlock)failure {
    return [[self sharedSessionManager] GET:path
        parameters:parameters
        headers:nil
        progress:nil
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
            success([self HTTPResponseForTask:task], responseObject);
        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
            failure([self HTTPResponseForTask:task], error);
        }];
}

#pragma mark - Private Methods

+ (AFHTTPSessionManager *)sharedSessionManager {
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:SCAPIBaseURLString];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPShouldSetCookies = NO;
        configuration.HTTPCookieStorage = nil;
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        requestSerializer.timeoutInterval = SCRequestTimeout;
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.completionQueue = dispatch_get_main_queue();
    });
    return manager;
}
+ (nullable NSHTTPURLResponse *)HTTPResponseForTask:(nullable NSURLSessionDataTask *)task {
    NSURLResponse *response = task.response;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        return (NSHTTPURLResponse *)response;
    }
    return nil;
}

@end

NS_ASSUME_NONNULL_END

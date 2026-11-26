//
//  SCNetworkClient.h
//  Spotify
//
//  Created by MacBook Air on 2026/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SCNetworkSuccessBlock)(NSHTTPURLResponse *_Nullable response, id _Nullable responseObject);
typedef void (^SCNetworkFailureBlock)(NSHTTPURLResponse *_Nullable response, NSError *error);

@interface SCNetworkClient : NSObject

+ (nullable NSURLSessionTask *)GET:(NSString *)path
                        parameters:(nullable NSDictionary<NSString *, id> *)parameters
                           success:(SCNetworkSuccessBlock)success
                           failure:(SCNetworkFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END

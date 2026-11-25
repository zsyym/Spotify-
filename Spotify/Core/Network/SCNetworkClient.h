//
//  SCNetworkClient.h
//  Spotify
//
//  Created by MacBook Air on 2026/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AFHTTPSessionManager;

@interface SCNetworkClient : NSObject

+(AFHTTPSessionManager *) sharedSessionManager;

@end

NS_ASSUME_NONNULL_END

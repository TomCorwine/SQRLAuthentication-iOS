//
//  SQRLAuthenticate.h
//  SQLRAuthentication
//
//  Created by Tom Corwine on 10/9/13.
//

typedef void (^SQRLAuthenticateCompletionBlock)(BOOL success, NSError *error);

@class SQRLSecretKey;
@interface SQRLAuthenticate : NSObject

- (void)authenticateForURL:(NSURL *)url secretKey:(SQRLSecretKey *)secretKey completionBlock:(SQRLAuthenticateCompletionBlock)completionBlock;

@end

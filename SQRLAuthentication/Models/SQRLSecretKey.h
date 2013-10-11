//
//  SQRLSecretKey.h
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

typedef void (^SQRLSecretKeyUpdateBlock)(float progress, BOOL done);
typedef void (^SQRLSecretKeyCompletionBlock)(NSData *secretKey);

@interface SQRLSecretKey : NSObject

@property (readonly, getter = doesSecretKeyExist) BOOL secretKeyExists;

//- (void)createPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQRLSecretKeyUpdateBlock)updateBlock;

- (void)beginGeneratingSecretKeyWithPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQRLSecretKeyUpdateBlock)updateBlock;
//- (void)beginGeneratingSecretKeyWithUpdateBlock:(SQRLSecretKeyUpdateBlock)updateBlock;
- (void)addSecretKeyDataArray:(NSArray *)dataArray;
- (void)cancelSecretKeyGeneration;

- (void)privateKeyForDomain:(NSString *)domain password:(NSString *)password completionBlock:(SQRLSecretKeyCompletionBlock)completionBlock
;

@end

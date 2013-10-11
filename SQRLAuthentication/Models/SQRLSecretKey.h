//
//  SQRLSecretKey.h
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

typedef void (^SQLSecretKeyUpdateBlock)(float progress, BOOL done);

@interface SQRLSecretKey : NSObject

@property (readonly, getter = doesSecretKeyExist) BOOL secretKeyExists;

//- (void)createPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQLSecretKeyUpdateBlock)updateBlock;

- (void)beginGeneratingSecretKeyWithPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQLSecretKeyUpdateBlock)updateBlock;
//- (void)beginGeneratingSecretKeyWithUpdateBlock:(SQLSecretKeyUpdateBlock)updateBlock;
- (void)addSecretKeyDataArray:(NSArray *)dataArray;
- (void)cancelSecretKeyGeneration;

- (NSData *)privateKeyForDomain:(NSString *)domain password:(NSString *)password;

@end

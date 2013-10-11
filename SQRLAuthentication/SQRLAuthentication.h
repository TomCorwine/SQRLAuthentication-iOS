//
//  SQRLAuthentication.h
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/7/13.
//

typedef void (^SQRLAuthenticationQRScanCompletionBlock)(NSString *domain, NSError *error);
typedef void (^SQRLAuthenticationSecretKeyUpdateBlock)(float progress, BOOL done, NSError *error);
typedef void (^SQRLAuthenticationCompletionBlock)(BOOL success, NSError *error);

@class SQRLAuthentication;
@protocol SQRLAuthenticationDelegate <NSObject>
- (void)sqrlAuthentication:(SQRLAuthentication *)authentication passwordUpdateProgress:(float)progress done:(BOOL)done error:(NSError *)error;
- (void)sqrlAuthentication:(SQRLAuthentication *)authentication secretKeyUpdateProgress:(float)progress done:(BOOL)done error:(NSError *)error;
- (void)sqrlAuthentication:(SQRLAuthentication *)authentication qrCodeWasScannedForDomain:(NSString *)domain error:(NSError *)error;
- (void)sqrlAuthentication:(SQRLAuthentication *)authentication didAuthenticateSuccessfully:(BOOL)success error:(NSError *)error;
@end

@class CALayer;
@interface SQRLAuthentication : NSObject

@property (weak) id<SQRLAuthenticationDelegate> delegate;

@property (readonly) CALayer *cameraPreviewLayer;

@property (readonly, getter = isURLCaptured) BOOL URLCaptured;
@property (readonly, getter = doesAtLeastOneUserExists) BOOL atLeastOneUserExists;

+ (id)sharedInstance;

- (void)createPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQRLAuthenticationSecretKeyUpdateBlock)updateBlock;
- (void)generateSecretKeyWithUpdateBlock:(SQRLAuthenticationSecretKeyUpdateBlock)updateBlock;

- (void)startScanQRCodeWithCompletionBlock:(SQRLAuthenticationQRScanCompletionBlock)completionBlock;
- (void)cancelScanQRCode;

- (void)authenticateWithCompletionBlock:(SQRLAuthenticationCompletionBlock)completionBlock;

@end

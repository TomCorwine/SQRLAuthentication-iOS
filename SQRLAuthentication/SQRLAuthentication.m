//
//  SQRLAuthentication.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/7/13.
//

#import "SQRLAuthentication.h"

#import "SQRLCamera.h"
#import "SQRLMotion.h"
#import "SQRLSecretKey.h"

typedef enum {
	SQRLAuthenticationCameraModeNone,
	SQRLAuthenticationCameraModeRandomData,
	SQRLAuthenticationCameraModeQRCode
} SQRLAuthenticationCameraMode;

@interface SQRLAuthentication () <SQRLCameraDelegate>

@property (strong) SQRLAuthenticationQRScanCompletionBlock qrScanCompletionBlock;
@property (strong) NSURL *capturedURL;
@property SQRLAuthenticationCameraMode mode;

@property (strong) SQRLCamera *camera;
@property (strong) SQRLMotion *motion;
@property (strong) SQRLSecretKey *secretKey;

@end

@implementation SQRLAuthentication

+ (id)sharedInstance
{
	static id sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	if (nil == (self = [super init]))
		return nil;

	static NSUInteger instanceCount;
	instanceCount++;
	NSAssert(instanceCount < 2, @"Only one instance of %1$@ can exist at a time. Use +[%1$@ sharedInstance] to retreive a reference to %1$@.", NSStringFromClass([self class]));

	self.mode = SQRLAuthenticationCameraModeNone;

	self.motion = [[SQRLMotion alloc] init];
	self.secretKey = [[SQRLSecretKey alloc] init];
	self.camera = [[SQRLCamera alloc] init];
	self.camera.delegate = self;

	return self;
}

- (void)createPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQRLAuthenticationSecretKeyUpdateBlock)updateBlock
{
	[self.secretKey beginGeneratingSecretKeyWithPassword:password computeDuration:seconds updateBlock:^(float progress, BOOL done) {
		if (updateBlock)
			updateBlock(progress, done, nil);

		if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:passwordUpdateProgress:done:error:)])
			[self.delegate sqrlAuthentication:self passwordUpdateProgress:progress done:done error:nil];
	}];
}

- (void)generateSecretKeyWithUpdateBlock:(SQRLAuthenticationSecretKeyUpdateBlock)updateBlock
{
	if (self.camera.error)
	{
		[self.camera stop];
		if (updateBlock)
			updateBlock(0.0, NO, self.camera.error);

		if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:secretKeyUpdateProgress:done:error:)])
			[self.delegate sqrlAuthentication:self secretKeyUpdateProgress:0.0 done:NO error:self.camera.error];
	}
	else
	{
		self.mode = SQRLAuthenticationCameraModeRandomData;
		[self.camera start];
		[self.secretKey beginGeneratingSecretKeyWithPassword:@"" computeDuration:0.5 updateBlock:^(float progress, BOOL done) {
			if (done)
			{
				self.mode = SQRLAuthenticationCameraModeNone;
				[self.camera stop];

				if (updateBlock)
					updateBlock(1.0, YES, nil);

				if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:secretKeyUpdateProgress:done:error:)])
					[self.delegate sqrlAuthentication:self secretKeyUpdateProgress:1.0 done:YES error:nil];
			}
			else
			{
				if (updateBlock)
					updateBlock(progress, NO, nil);

				if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:secretKeyUpdateProgress:done:error:)])
					[self.delegate sqrlAuthentication:self secretKeyUpdateProgress:progress done:NO error:nil];
			}
		}];
	}
}

- (void)startScanQRCodeWithCompletionBlock:(SQRLAuthenticationQRScanCompletionBlock)completionBlock
{
	self.qrScanCompletionBlock = completionBlock;
	self.mode = SQRLAuthenticationCameraModeQRCode;
	[self.camera start];
}

- (void)cancelScanQRCode
{
	self.qrScanCompletionBlock = nil;
	self.mode = SQRLAuthenticationCameraModeNone;
	[self.camera stop];
}

- (void)authenticateWithCompletionBlock:(SQRLAuthenticationCompletionBlock)completionBlock
{
	if (NO == self.URLCaptured)
	{
		NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{}];
		if (completionBlock)
			completionBlock(NO, error);

		if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:didAuthenticateSuccessfully:error:)])
			[self.delegate sqrlAuthentication:self didAuthenticateSuccessfully:NO error:error];

		return;
	}

	if (completionBlock)
		completionBlock(YES, nil);

	if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:didAuthenticateSuccessfully:error:)])
		[self.delegate sqrlAuthentication:self didAuthenticateSuccessfully:YES error:nil];
}

#pragma mark - Accessors

- (BOOL)isURLCaptured
{
	return (nil != self.capturedURL);
}

- (BOOL)doesAtLeastOneUserExists
{
	return self.secretKey.secretKeyExists;
}

- (CALayer *)cameraPreviewLayer
{
	return (CALayer *)self.camera.previewLayer;
}

#pragma mark - SQLCamera Delegate

- (void)camera:(SQRLCamera *)cameraHandler didCaptureData:(NSData *)data
{
	// only add data to the secretKey instance if we're generating a key and device is being waved around
	if (SQRLAuthenticationCameraModeRandomData == self.mode && self.motion.deviceMoving)
		[self.secretKey addSecretKeyDataArray:@[data, self.motion.data]];
}

- (void)camera:(SQRLCamera *)cameraHandler didCaptureQRCode:(NSString *)string
{
	self.capturedURL = [NSURL URLWithString:string];
	if (SQRLAuthenticationCameraModeQRCode == self.mode)
	{
		if (self.capturedURL) //TODO: check if this is a SQRL url
		{
			[self.camera stop];

			if (self.qrScanCompletionBlock)
				self.qrScanCompletionBlock(self.capturedURL.host, nil);
			self.qrScanCompletionBlock = nil;

			if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:qrCodeWasScannedForDomain:error:)])
				[self.delegate sqrlAuthentication:self qrCodeWasScannedForDomain:self.capturedURL.host error:nil];
		}
		else
		{
			NSError *error = [NSError errorWithDomain:@"" code:9 userInfo:@{@"":@""}];

			if (self.qrScanCompletionBlock)
				self.qrScanCompletionBlock(nil, error);
			self.qrScanCompletionBlock = nil;

			if ([self.delegate respondsToSelector:@selector(sqrlAuthentication:qrCodeWasScannedForDomain:error:)])
				[self.delegate sqrlAuthentication:self qrCodeWasScannedForDomain:nil error:error];
		}
	}
}

@end

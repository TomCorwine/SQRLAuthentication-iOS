//
//  SQRLCamera.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

#import "SQRLCamera.h"

#import <AVFoundation/AVFoundation.h>

@interface SQRLCamera () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (strong) NSError *error;
@property (strong) AVCaptureSession *session;
@property (strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation SQRLCamera

- (id)init
{
	if (nil == (self = [super init]))
		return nil;

	static NSUInteger instanceCount;
	instanceCount++;
	NSAssert(instanceCount < 2, @"Only one instance of %@ can exist at a time.", NSStringFromClass([self class]));

	self.session = [[AVCaptureSession alloc] init];
	if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh])
		self.session.sessionPreset = AVCaptureSessionPresetHigh;
	else
		[self createErrorWithDomain:@"camera can not support capture session" code:SQRLCameraErrorSessionPreset localizedDescription:NSLocalizedString(@"Error initializing camera.", nil)];

	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (error)
	{
		self.error = error;
	}
	else
	{
		if ([self.session canAddInput:input])
			[self.session addInput:input];
		else
			[self createErrorWithDomain:@"camera can not add input" code:SQRLCameraErrorInput localizedDescription:NSLocalizedString(@"Error initializing camera.", nil)];
	}

	AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
	if ([self.session canAddOutput:output])
		[self.session addOutput:output];
	else
		[self createErrorWithDomain:@"camera can not add output" code:SQRLCameraErrorOutput localizedDescription:NSLocalizedString(@"Error initializing camera.", nil)];

	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
	self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

	dispatch_queue_t queue = dispatch_queue_create("com.tomsiphoneapps.sqlauthenticator.capturequeue", NULL);
	[output setSampleBufferDelegate:self queue:queue];

	AVCaptureMetadataOutput *metdataOutput = [[AVCaptureMetadataOutput alloc] init];
	[self.session addOutput:metdataOutput];
	if ([metdataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode])
	{
		metdataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
		[metdataOutput setMetadataObjectsDelegate:self queue:queue];
	}
	else
	{
		[self createErrorWithDomain:@"bar code scanning not available" code:SQRLCameraErrorMetadata localizedDescription:NSLocalizedString(@"Bar code scanning is not available on this device.", nil)];
	}

	return self;
}

- (void)stop
{
	if (self.session.isRunning)
		[self.session stopRunning];
}

- (void)start
{
	if (NO == self.session.isRunning)
		[self.session startRunning];
}

#pragma mark - Helpers

- (void)createErrorWithDomain:(NSString *)domain code:(NSUInteger)code localizedDescription:(NSString *)localizedDescription
{
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey:localizedDescription};
	self.error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

#pragma mark - AVCaptureVideoDataOutputSampleBuffer Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	// I'm sure there's a better way of converting the CMSampleBufferRef to NSData
	// From SO post http://stackoverflow.com/questions/6189409/how-to-get-bytes-from-cmsamplebufferref-to-send-over-network
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    //size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    void *src_buff = CVPixelBufferGetBaseAddress(imageBuffer);
    NSData *data = [NSData dataWithBytes:src_buff length:(bytesPerRow * height)];
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

	dispatch_async(dispatch_get_main_queue(), ^{
		if ([self.delegate respondsToSelector:@selector(camera:didCaptureData:)])
			[self.delegate camera:self didCaptureData:data];
	});
}

#pragma mark - AVCaptureMetadataOutputObjects Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	AVMetadataMachineReadableCodeObject *metadataObject;
	for (AVMetadataMachineReadableCodeObject *iMetadataObject in metadataObjects)
	{
		if ([iMetadataObject.type isEqualToString:AVMetadataObjectTypeQRCode])
		{
			metadataObject = iMetadataObject;
			break;
		}
	}

	if (nil == metadataObject)
		return;

	dispatch_async(dispatch_get_main_queue(), ^{
		if ([self.delegate respondsToSelector:@selector(camera:didCaptureQRCode:)])
			[self.delegate camera:self didCaptureQRCode:metadataObject.stringValue];
	});
}

@end

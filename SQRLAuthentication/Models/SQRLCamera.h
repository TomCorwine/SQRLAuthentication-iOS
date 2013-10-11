//
//  SQRLCamera.h
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

typedef enum {
	SQRLCameraErrorSessionPreset = 901,
	SQRLCameraErrorInput = 902,
	SQRLCameraErrorOutput = 903,
	SQRLCameraErrorMetadata = 904,
} SQRLCameraError;

@class SQRLCamera;
@protocol SQRLCameraDelegate <NSObject>
- (void)camera:(SQRLCamera *)camera didCaptureData:(NSData *)data;
- (void)camera:(SQRLCamera *)camera didCaptureQRCode:(NSString *)string;
@end

@class AVCaptureVideoPreviewLayer;
@interface SQRLCamera : NSObject

@property (readonly, strong) NSError *error;
@property (weak) id<SQRLCameraDelegate> delegate;
@property (readonly, strong) AVCaptureVideoPreviewLayer *previewLayer;

- (void)stop;
- (void)start;

@end

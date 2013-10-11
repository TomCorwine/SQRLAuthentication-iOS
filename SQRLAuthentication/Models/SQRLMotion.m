//
//  SQRLMotion.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

#import "SQRLMotion.h"

#import "Categories.h"

#import <CoreMotion/CoreMotion.h>

#define kMotionThreshold		0.5

@interface SQRLMotion ()
@property (strong) CMMotionManager *motionManager;
@property (strong) NSMutableData *mutableData;
@property (getter = isDeviceMoving) BOOL deviceMoving;
@end

@implementation SQRLMotion

- (id)init
{
	if (nil == (self = [super init]))
		return nil;

	static NSUInteger instanceCount;
	instanceCount++;
	NSAssert(instanceCount < 2, @"Only one instance of %@ can exist at a time.", NSStringFromClass([self class]));

	self.motionManager = [[CMMotionManager alloc] init];
	self.mutableData = [[NSMutableData alloc] init];

	self.motionManager.accelerometerUpdateInterval = 0; // Generate events as fast as harware allows
	[self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
		CMAcceleration acceleration = motion.userAcceleration;
		CMRotationRate rotation = motion.rotationRate;
		CMAcceleration gravity = motion.gravity;
		CMAttitude *attitude = motion.attitude;

		// If any accelerometer or gyro parmeter shows > kMotionThreshold g's, consider the device in motion
		self.deviceMoving = ((acceleration.x > kMotionThreshold || acceleration.x < -kMotionThreshold)
							 || (acceleration.y > kMotionThreshold || acceleration.y < -kMotionThreshold)
							 || (acceleration.z > kMotionThreshold || acceleration.z < -kMotionThreshold)
							 || (rotation.x > kMotionThreshold || rotation.x < -kMotionThreshold)
							 || (rotation.y > kMotionThreshold || rotation.y < -kMotionThreshold)
							 || (rotation.z > kMotionThreshold || rotation.z < -kMotionThreshold));

		NSString *string = [NSString stringWithFormat:@"%f%f%f%f%f%f%f%f%f%f%f%f",
							acceleration.x, acceleration.y, acceleration.x,
							rotation.x, rotation.y, rotation.z,
							gravity.x, gravity.y, gravity.z,
							attitude.roll, attitude.pitch, attitude.yaw];
		[self.mutableData appendData:string.data];
	}];

	return self;
}

- (NSData *)data
{
	NSData *data = self.mutableData;
	self.mutableData = [[NSMutableData alloc] init];
	return data;
}

@end

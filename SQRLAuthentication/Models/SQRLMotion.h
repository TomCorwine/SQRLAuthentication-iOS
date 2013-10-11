//
//  SQRLMotion.h
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

@interface SQRLMotion : NSObject

@property (readonly, getter = isDeviceMoving) BOOL deviceMoving;
@property (readonly) NSData *data;

@end

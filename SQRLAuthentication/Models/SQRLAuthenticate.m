//
//  SQRLAuthenticate.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/9/13.
//

#import "SQRLAuthenticate.h"

#import "SQRLSecretKey.h"

@implementation SQRLAuthenticate

- (id)init
{
	if (nil == (self = [super init]))
		return nil;

	static NSUInteger instanceCount;
	instanceCount++;
	NSAssert(instanceCount < 2, @"Only one instance of %@ can exist at a time.", NSStringFromClass([self class]));

	return self;
}

- (void)authenticateForURL:(NSURL *)url secretKey:(SQRLSecretKey *)secretKey completionBlock:(SQRLAuthenticateCompletionBlock)completionBlock
{
	//NSData *privateKey = [secretKey privateKeyForDomain:url.host];
}

@end

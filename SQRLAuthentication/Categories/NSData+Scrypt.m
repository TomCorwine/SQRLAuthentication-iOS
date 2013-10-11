//
//  NSData+Scrypt.m
//
//  Created by Tom Corwine on 10/9/13.
//

#import "NSData+Scrypt.h"

#import <CommonCrypto/CommonKeyDerivation.h>

@implementation NSData (Scrypt)

- (void)scryptPBKDF2WithKey:(NSData *)key duration:(NSTimeInterval)seconds completionBlock:(NSDataScryptCompletionBlock)completionBlock
{
	dispatch_queue_t queue = dispatch_queue_create("com.tomsiphoneapps.sqrlauthentication.pbkdf2", NULL);
	dispatch_async(queue, ^{
#warning Apple's PBKDF2 crypto function only supports the SHA family of hashes. This is here for developement purposes, but need to be re-implemented
		int outputLength = (512 / 8);
		CCPBKDFAlgorithm algorithm = kCCHmacAlgSHA512;
		// From SO post http://stackoverflow.com/questions/8569555/pbkdf2-using-commoncrypto-on-ios
		// Calculate the number of rounds we need on this hardware to achive our desired time to hash
		int rounds = CCCalibratePBKDF(kCCPBKDF2, // this is the only valid option
									  self.length, // length of input
									  key.length, // length of salt
									  algorithm, // algorithm to use
									  outputLength, // output length in bytes
									  (seconds * 1000)); // time to hash in ms

		unsigned char result[32];
		CCKeyDerivationPBKDF(kCCPBKDF2,
							 self.bytes,
							 self.length,
							 key.bytes,
							 key.length,
							 algorithm,
							 rounds,
							 result,
							 outputLength);
		NSData *data = [NSData dataWithBytes:result length:outputLength];

		dispatch_async(dispatch_get_main_queue(), ^{
			if (completionBlock)
				completionBlock(data, rounds);
		});
	});
}

@end

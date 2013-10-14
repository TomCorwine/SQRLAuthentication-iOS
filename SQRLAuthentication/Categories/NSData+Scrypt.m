//
//  NSData+Scrypt.m
//
//  Created by Tom Corwine on 10/9/13.
//

#import "NSData+Scrypt.h"

#import "scryptenc.h"

@implementation NSData (Scrypt)

- (void)scryptPBKDWithPassword:(NSString *)password duration:(NSTimeInterval)seconds completionBlock:(NSDataScryptCompletionBlock)completionBlock
{
	dispatch_queue_t queue = dispatch_queue_create("com.tomsiphoneapps.sqrlauthentication.scrypt", NULL);
	dispatch_async(queue, ^{
		/**
		 * scryptenc_buf(inbuf, inbuflen, outbuf, passwd, passwdlen,
		 *     maxmem, maxmemfrac, maxtime):
		 * Encrypt inbuflen bytes from inbuf, writing the resulting inbuflen + 128
		 * bytes to outbuf.
		 */
		const uint8_t *in_buffer = (uint8_t *)self.bytes;
		uint8_t out_buffer[sizeof(in_buffer) + 128];
		int N = 0;
		double r = 8;
		double p = 0;
		scryptenc_buf(in_buffer, sizeof(in_buffer), out_buffer, (uint8_t *)password.UTF8String, password.length, N, r, p);

		NSData *data = [NSData dataWithBytes:out_buffer length:sizeof(out_buffer)];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completionBlock)
				completionBlock(data);
		});
	});
}

@end

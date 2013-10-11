//
//  NSData+Random.m
//
//  Created by Tom Corwine on 10/7/13.
//

#import "NSData+Random.h"

@implementation NSData (Random)

+ (NSData *)randomDataWithLength:(NSUInteger)length
{
	// From SO post http://stackoverflow.com/questions/4917968/best-way-to-generate-nsdata-object-with-random-bytes-of-a-specific-length
	// Using /dev/random instead of /dev/urandom as it's more secure
    NSMutableData *mutableData = [NSMutableData dataWithLength:length];
    [[NSInputStream inputStreamWithFileAtPath:@"/dev/random"] read:(uint8_t *)mutableData.mutableBytes maxLength:length];
    return mutableData;
}

@end

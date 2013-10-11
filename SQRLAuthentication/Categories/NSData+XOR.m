//
//  NSData+XOR.m
//
//  Created by Tom Corwine on 10/6/13.
//

#import "NSData+XOR.h"

@implementation NSData (XOR)

- (NSData *)dataXORdWithData:(NSData *)data
{
//TODO: #warning This needs to be thoroughly audited, I'm not sure I follow this correctly
	// From SO post http://stackoverflow.com/questions/11724527/xor-file-encryption-in-ios
	NSMutableData *result = self.mutableCopy;

    // Get pointer to data to obfuscate
    char *dataPtr = (char *)result.mutableBytes;

    // Get pointer to key data
    char *keyData = (char *)data.bytes;

    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;

    // For each character in data, xor with current value in key
    for (int x = 0; x < self.length; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;

        // If at end of key data, reset count and
        // set key pointer back to start of key value
        if (++keyIndex == self.length)
		{
            keyIndex = 0;
			keyPtr = keyData;
		}
	}

    return result;
}

@end

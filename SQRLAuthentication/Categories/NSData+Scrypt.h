//
//  NSData+Scrypt.h
//
//  Created by Tom Corwine on 10/9/13.
//

#import <Foundation/Foundation.h>

typedef void (^NSDataScryptCompletionBlock)(NSData *data, int rounds);

@interface NSData (Scrypt)

- (void)scryptPBKDF2WithKey:(NSData *)key duration:(NSTimeInterval)seconds completionBlock:(NSDataScryptCompletionBlock)completionBlock;

@end

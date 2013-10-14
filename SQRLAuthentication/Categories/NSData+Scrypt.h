//
//  NSData+Scrypt.h
//
//  Created by Tom Corwine on 10/9/13.
//

#import <Foundation/Foundation.h>

typedef void (^NSDataScryptCompletionBlock)(NSData *data);

@interface NSData (Scrypt)

- (void)scryptPBKDWithPassword:(NSString *)password duration:(NSTimeInterval)seconds completionBlock:(NSDataScryptCompletionBlock)completionBlock;

@end

//
//  NSData+Scrypt.h
//  SQLAuthentication
//
//  Created by Tom Corwine on 10/9/13.
//  Copyright (c) 2013 Tom Corwine. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NSDataScryptCompletionBlock)(NSData *data, int rounds);

@interface NSData (Scrypt)

- (void)scryptPBKDF2WithKey:(NSData *)key duration:(NSTimeInterval)seconds completionBlock:(NSDataScryptCompletionBlock)completionBlock;

@end

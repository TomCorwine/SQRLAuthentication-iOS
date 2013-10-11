//
//  NSData+Hash.h
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/10/13.
//  Copyright (c) 2013 Tom Corwine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Hash)

@property (readonly) NSString *md5String;
@property (readonly) NSString *sha1String;
@property (readonly) NSString *sha256String;
@property (readonly) NSString *sha512String;

- (NSString *)hmacSHA1StringWithKey:(NSString *)key;
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

@end

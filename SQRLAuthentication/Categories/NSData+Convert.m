//
//  NSData+Convert.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/11/13.
//  Copyright (c) 2013 Tom Corwine. All rights reserved.
//

#import "NSData+Convert.h"

@implementation NSData (Convert)

- (NSString *)newString
{
	return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end

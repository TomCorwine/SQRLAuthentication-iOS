//
//  NSString+Convert.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/11/13.
//  Copyright (c) 2013 Tom Corwine. All rights reserved.
//

#import "NSString+Convert.h"

@implementation NSString (Convert)

- (NSData *)data
{
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

//
//  NSString+Convert.m
//
//  Created by Tom Corwine on 10/11/13.
//

#import "NSString+Convert.h"

@implementation NSString (Convert)

- (NSData *)data
{
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

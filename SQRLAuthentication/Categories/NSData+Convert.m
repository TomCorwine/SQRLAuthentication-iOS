//
//  NSData+Convert.m
//
//  Created by Tom Corwine on 10/11/13.
//

#import "NSData+Convert.h"

@implementation NSData (Convert)

- (NSString *)newString
{
	return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end

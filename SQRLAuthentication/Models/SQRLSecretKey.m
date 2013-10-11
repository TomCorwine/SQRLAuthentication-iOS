//
//  SQRLSecretKey.m
//  SQRLAuthentication
//
//  Created by Tom Corwine on 10/6/13.
//

#import "SQRLSecretKey.h"

#import "PDKeychainBindings.h"

#import "NSString+Hash.h"
#import "NSData+XOR.h"
#import "NSData+Random.h"
#import "NSData+Hash.h"
#import "NSData+Scrypt.h"

#define kNumberOfKeyGeneratingSecondsRequired	5
#define kSecretKeyStorageKey					@"SecretKeyStorageKey"

@interface SQRLSecretKey ()
@property (strong) NSTimer *generationTimer;
@property (strong) NSData *passwordHash;
@property (strong) NSMutableString *mutableString;
@property (strong) SQLSecretKeyUpdateBlock updateBlock;
@property (getter = isNewDataAvailable) BOOL newDataAvailable;
@property NSTimeInterval elapsedSecondsOfCollectingData;
@end

@implementation SQRLSecretKey

/*
- (void)createPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQLSecretKeyUpdateBlock)updateBlock
{
	seconds = MAX(seconds, 0.5); // don't allow a duration of less than 0.5 seconds
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	dispatch_queue_t queue = dispatch_queue_create("com.tomsiphoneapps.sqrlauthentication.passwordhash", NULL);
	dispatch_async(queue, ^{
		NSData *hashedPassword = nil;
	});
}
*/

- (void)beginGeneratingSecretKeyWithPassword:(NSString *)password computeDuration:(NSTimeInterval)seconds updateBlock:(SQLSecretKeyUpdateBlock)updateBlock
{
	//NSAssert(self.passwordHash, @"-[%1$@ createPassword:computeDuration:updateBlock:] must be called before calling -[%1$@ beginGeneratingSecretKeyWithUpdateBlock:]", NSStringFromClass([self class]));

	self.generationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(generationTimerDidFire:) userInfo:nil repeats:YES];

	self.updateBlock = updateBlock;
	self.mutableString = [[NSMutableString alloc] init];

	if (self.updateBlock)
		self.updateBlock(0, NO);
}

- (void)addSecretKeyDataArray:(NSArray *)dataArray
{
	NSAssert(self.mutableString, @"-[%1$@ beginGeneratingSecretKeyWithUpdateBlock:] must be called before calling -[%1$@ addSecretKeyDataArray:]", NSStringFromClass([self class]));
	NSAssert(dataArray.count, @"-[%@ addSecretKeyDataArray:] should be passed an NSArray with at least on NSData object", NSStringFromClass([self class]));

	NSData *data = dataArray[0]; // Start with the first data object
	// Iterate through the rest of the data objects (if any) and xor with what we have already
	for (int i = 1; i < dataArray.count - 1; i++)
	{
		NSData *newData = dataArray[i];
		data = [data dataXORdWithData:newData];
	}

	[self.mutableString appendString:data.sha256String];

	if (self.elapsedSecondsOfCollectingData > kNumberOfKeyGeneratingSecondsRequired) // We're done
	{
		data = [self.mutableString.sha256String dataUsingEncoding:NSUTF8StringEncoding];
		NSData *randomData = [NSData randomDataWithLength:data.length]; // Add random data from system
		data = [data dataXORdWithData:randomData];
		self.secretKey = data;

		self.mutableString = nil;
		self.generationTimer = nil;
		if (self.updateBlock)
			self.updateBlock(1.0, YES);
		self.updateBlock = nil;
	}
	else // Update progress
	{
		if (self.updateBlock)
			self.updateBlock(self.elapsedSecondsOfCollectingData / (float)kNumberOfKeyGeneratingSecondsRequired, NO);
	}
}

- (void)cancelSecretKeyGeneration
{
	self.generationTimer = nil;
	self.mutableString = nil;
	self.updateBlock = nil;
}

- (NSData *)privateKeyForDomain:(NSString *)domain password:(NSString *)password
{
	NSData *secretKey = [self secretKeyWithPassword:password];
	//NSString *secretKeyString = [[NSString alloc] initWithData: encoding:NSUTF8StringEncoding];
	//NSString *privateKeyString = [domain hmacSHA256StringWithKey:secretKeyString];
	return nil ;//[privateKeyString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Accessors

- (BOOL)doesSecretKeyExist
{
	return NO; //(nil != self.secretKey);
}

#pragma mark - Helpers

- (void)setSecretKey:(NSData *)secretKey
{
	NSString *string = [[NSString alloc] initWithData:secretKey encoding:NSUTF8StringEncoding];
	[[PDKeychainBindings sharedKeychainBindings] setString:string forKey:kSecretKeyStorageKey];
}

- (NSData *)secretKeyWithPassword:(NSString *)password
{
	NSString *secretKeyString = [[PDKeychainBindings sharedKeychainBindings] objectForKey:kSecretKeyStorageKey];
	return [secretKeyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)generationTimerDidFire:(NSTimer *)timer
{
	// store oldTimeInterval so we add elapsed time (since this method was last called) if new data has been appended
	static NSTimeInterval oldTimeInterval;
	// store oldDataLength so we can tell if data has been appended since this method was last called
	static NSUInteger oldDataLength;
	NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
	NSUInteger dataLength = self.mutableString.length;

	// generationTimer fires off before mutableString is allocated. If mutableString is nil,
	// then we're just starting off and the old* variables should be reset. This isn't a big deal
	// the first time we try to generate a user's secret key, but this may not be the first time.
	// The user may have canceled and is starting over.
	if (nil == self.mutableString)
	{
		oldTimeInterval = timeInterval;
		oldDataLength = dataLength;
	}

	self.newDataAvailable = (dataLength > oldDataLength);
	// we only want to increment the timeInterval if new data was added this prevents someone
	// from just letting their device sit on a table for 5 seconds while we generate the secret key
	if (self.newDataAvailable)
		self.elapsedSecondsOfCollectingData += (timeInterval - oldTimeInterval);

	oldTimeInterval = timeInterval;
	oldDataLength = dataLength;
}

@end

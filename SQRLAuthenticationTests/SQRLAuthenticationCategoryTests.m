//
//  SQRLAuthenticationCategoryTests.m
//  SQRLAuthenticationCategoryTests
//
//  Created by Tom Corwine on 10/7/13.
//

#import <XCTest/XCTest.h>

#import "NSData+Random.h"
#import "NSData+XOR.h"
#import "NSData+Hash.h"
#import "NSString+Hash.h"

@interface SQRLAuthenticationCategoryTests : XCTestCase
@end

@implementation SQRLAuthenticationCategoryTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRandom
{
	// Obviously, we can't test for randomness. We could possibly test for non-randomness,
	// but having a test that can possibly fail but never pass is not good testing practice.
	// A test should only pass if it's code executed correctly and as deterministicly expected;
	// It should not pass if it's not incorrect but possibly not correct.
	// We *want* the random function to be non-deterministic! Therefore, untestable.
	// At the very least, we can test if the random data output is the same length as requested.
	NSUInteger byteLength = 512;
	NSData *randomData = [NSData randomDataWithLength:byteLength];
	XCTAssertTrue(randomData.length == byteLength, @"Random data function output byte length is not the same as requested.");
}

- (void)testXor
{
	NSData *aData = [[NSData alloc] initWithBase64EncodedString:@"YW4gb2xkIG1hbiBzdGF5cyBhdCBob21l" options:0];
	NSData *bData = [[NSData alloc] initWithBase64EncodedString:@"RG93biBvbiB0aGUgcHJhaXJpZSBmYXJt" options:0];
	NSData *xorData = [aData dataXORdWithData:bData];
	NSString *xorString = [xorData base64EncodedStringWithOptions:0];
	XCTAssertTrue([xorString isEqualToString:@"JQFXAUwLTk0VBkVTBBMYGlIIEQAODh8I"], @"XOR function did not produce expected output.");
}

- (void)testSHA256String
{
	NSString *string = @"This string needs to be hashed.";
	NSString *hashedOutput = string.sha256String;
	XCTAssertTrue([hashedOutput isEqualToString:
	@"1e7fbab426d2f180a703b350b417a218efbc9a4b576890d6e349d594d474cff7"],
	@"SHA256 string hash function did not produce expected output.");
}

- (void)testSHA512String
{
	NSString *string = @"This string needs to be hashed.";
	NSString *hashedOutput = string.sha512String;
	XCTAssertTrue([hashedOutput isEqualToString:
	@"601ac9cb5d2dd8612298502f8b350247f4c85894c48c791b26e540aa171246039a8b0a2b9e8b8335a5d948c25dc0a57e9a4091d261eb384f0ca22ed64317d61e"],
	@"SHA512 string hash function did not produce expected output.");
}

- (void)testSHA256Data
{
	NSData *data = [@"This string needs to be hashed." dataUsingEncoding:NSUTF8StringEncoding];
	NSString *hashedOutput = data.sha256String;
	XCTAssertTrue([hashedOutput isEqualToString:
	@"1e7fbab426d2f180a703b350b417a218efbc9a4b576890d6e349d594d474cff7"],
	@"SHA256 data hash function did not produce expected output.");
}

- (void)testSHA512Data
{
	NSData *data = [@"This string needs to be hashed." dataUsingEncoding:NSUTF8StringEncoding];
	NSString *hashedOutput = data.sha512String;
	XCTAssertTrue([hashedOutput isEqualToString:
	@"601ac9cb5d2dd8612298502f8b350247f4c85894c48c791b26e540aa171246039a8b0a2b9e8b8335a5d948c25dc0a57e9a4091d261eb384f0ca22ed64317d61e"],
	@"SHA512 data hash function did not produce expected output.");
}

@end

//
//  DMEncryptTest.m
//  ExampleTests
//
//  Created by wushengzhong on 2019/8/16.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <DMEncrypt/DMEncrypt.h>

@interface DMEncryptTest : XCTestCase

@end

@implementation DMEncryptTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testEncrypt {
    NSString *ori = @"woshiceshi";
    NSString *expect = @"LmRlaxAG9amHo52cWqfK";
    NSString *actual = [DMEncrypt encryptString:ori];
    XCTAssertEqualObjects(expect, actual, @"[DMEncrypt] => f:[encryptString:], 加密方法错误");
}

- (void)testDecrypt {
    NSString *ori = @"LmRlaxAG9amHo52cWqfK";
    NSString *expect = @"woshiceshi";
    NSString *actual = [DMEncrypt decryptString:ori];
    XCTAssertEqualObjects(expect, actual, @"[DMEncrypt] => f:[decryptString:], 解密方法错误");
}

- (void)testPerformanceEncrypt {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [DMEncrypt encryptString:@"woshiceshi"];
    }];
}

- (void)testPerformanceDecrypt {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [DMEncrypt decryptString:@"LmRlaxAG9amHo52cWqfK"];
    }];
}

@end

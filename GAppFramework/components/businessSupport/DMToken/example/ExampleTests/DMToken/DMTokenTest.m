//
//  DMTokenTest.m
//  ExampleTests
//
//  Created by wushengzhong on 2019/8/16.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DMToken/DMSToken.h>

@interface DMTokenTest : XCTestCase
@end

@implementation DMTokenTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAccessToken {
    XCTAssertNotNil([DMSToken accessToken]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

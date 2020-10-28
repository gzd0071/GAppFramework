//
//  HttpConfigTests.m
//  ExampleTests
//
//  Created by wushengzhong on 2019/8/19.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <HttpConfig/HttpConfig.h>
#import <HttpRequest/HttpRequest.h>

@interface HttpConfigTests : XCTestCase

@end

@implementation HttpConfigTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testHttpBaseUrl {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
#if DEBUG
    XCTAssertNotNil([[HttpConfig new] requestBaseUrl], @"请求配置HttpConfig:requestBaseUrl");
#else
    NSString *baseUrl = [[HttpConfig new] requestBaseUrl];
    XCTAssertFalse([baseUrl containsString:@"test"] || [baseUrl containsString:@"sim"], @"请求配置BaseURL路径是测试环境或sim环境");
#endif
}

- (void)testHttpConnected {
    XCTestExpectation *exp = [self expectationWithDescription:@"请求配置网络异常"];
    HttpRequest *req = [HttpRequest jsonRequest].urlString(@"/api/v2/client/im/filterword");
    [req.task continueWithBlock:^id(BFTask<HttpResult *> *t) {
        XCTAssertTrue(t.result.suc);
        [exp fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        if (error) {
            NSLog(@"请求超时...");
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

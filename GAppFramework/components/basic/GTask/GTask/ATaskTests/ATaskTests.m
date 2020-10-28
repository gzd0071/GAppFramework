//
//  ATaskTests.m
//  ATaskTests
//
//  Created by wushengzhong on 2019/11/9.
//  Copyright © 2019 ShiChengYouPin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATask.h"
#import "ATask+Fwd.h"

/// ATask Domain
#define ATaskTestErrorDomain @"ATaskErrorDomain"

/// NSError
/// @param code 错误码
static inline NSError *dummyWithCode(NSInteger code) {
    return [NSError errorWithDomain:ATaskTestErrorDomain code:rand() userInfo:@{NSLocalizedDescriptionKey: @(code).stringValue}];
}
/// NSError 生成随机错误码NSError
static inline NSError *dummy() {
    return dummyWithCode(rand());
}
/// ATask 生成一个异步线程的完成任务
static inline ATask *fulfillLater() {
    return [ATask taskWithResolverBlock:^(ATResolver resolver) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            resolver(ATaskResultFulfilled, @1);
        });
    }];
}
/// ATask 生成一个异步线程的失败任务
static inline ATask *rejectLater() {
    return [ATask taskWithResolverBlock:^(ATResolver resolver) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                resolver(ATaskResultRejected, dummy());
            });
        });
    }];
}

@interface ATaskTests : XCTestCase
@end

@implementation ATaskTests

/// 测试TaskWithValue: resolve
- (void)test_01_resolve {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:@1];
    task.then(^(NSNumber *t) {
        [ex1 fulfill];
        XCTAssertEqual(t.intValue, 1);
    });
    task.catch(^(ATask *t) {
        XCTFail();
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}
/// 测试TaskWithValue: reject
- (void)test_02_reject {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:dummyWithCode(2)];
    task.then(^(NSNumber * t) {
        XCTFail();
    });
    task.catch(^(NSError *t) {
        XCTAssertEqualObjects(t.localizedDescription, @"2");
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}
/// 测试catch
- (void)test_03_return_error {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:@2];
    task.then(^(NSNumber *t) {
        return [NSError errorWithDomain:@"a" code:3 userInfo:nil];
    }).catch(^(NSError *t) {
        [ex1 fulfill];
        XCTAssertEqual(3, t.code);
    });
    task.catch(^(NSError *t) {
        XCTFail();
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}
- (void)test_04_throw_and_bubble_more {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:@4];
    task.then(^{
        return dummy();
    }).then(^{
        XCTFail();
    }).catch(^(NSError *t){
        [ex1 fulfill];
        XCTAssertEqualObjects(t.domain, ATaskTestErrorDomain);
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}
- (void)test_05_throw_and_bubble {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@5].then(^(NSNumber *t){
        XCTAssertEqual(5, [t intValue]);
        return [NSError errorWithDomain:@"a" code:[t intValue] userInfo:nil];
    }).catch(^(NSError *t){
        XCTAssertEqual(t.code, 5);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_06_return_error {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@5].then(^(NSNumber *t){
        return dummy();
    }).catch(^(NSError *t){
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_07_can_then_error {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@5].then(^(NSNumber *t){
        [ex1 fulfill];
        XCTAssertEqualObjects(@5, t);
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_08_can_fail_rejected {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:dummyWithCode(1)].then(^(NSNumber *t){
        XCTFail();
    }).catch(^(NSError *t){
        [ex1 fulfill];
        XCTAssertEqualObjects(@"1", t.localizedDescription);
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_09_async {
    id ex1 = [self expectationWithDescription:@""];
    __block int x = 0;
    [ATask taskWithValue:@(1)].then(^{
        XCTAssertEqual(x, 0);
        x++;
    }).then(^{
        XCTAssertEqual(x, 1);
        x++;
    }).then(^{
        XCTAssertEqual(x, 2);
        x++;
    }).then(^{
        XCTAssertEqual(x, 3);
        x++;
    }).then(^{
        XCTAssertEqual(x, 4);
        x++;
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertEqual(x, 5);
}

- (void)test_10_then_return_resolved_task {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@10].then(^(NSNumber *t){
       XCTAssertEqualObjects(@10, t);
       return [ATask taskWithValue:@100];
    }).then(^(NSNumber *t){
       XCTAssertEqualObjects(@100, t);
       [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_11_then_returns_pending_task {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@10].then(^{
        return fulfillLater();
    }).then(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_12_then_returns_recursive_task {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    __block int x = 0;
    fulfillLater().then(^{
        NSLog(@"1");
        XCTAssertEqual(x++, 0);
        return fulfillLater().then(^{
            NSLog(@"2");
            XCTAssertEqual(x++, 1);
            return fulfillLater().then(^{
                NSLog(@"3");
                XCTAssertEqual(x++, 2);
                return fulfillLater().then(^{
                    NSLog(@"4");
                    XCTAssertEqual(x++, 3);
                    [ex2 fulfill];
                    return @"foo";
                });
            });
        });
    }).then(^(id o){
        NSLog(@"5");
        XCTAssertEqualObjects(@"foo", o);
        XCTAssertEqual(x++, 4);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(x, 5);
}

- (void)test_13_then_returns_recursive_tasks_that_fails {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    
    fulfillLater().then(^{
        return fulfillLater().then(^{
            return fulfillLater().then(^{
                return fulfillLater().then(^{
                    [ex2 fulfill];
                    return dummy();
                });
            });
        });
    }).then(^{
        XCTFail();
    }).catch(^(NSError *e){
        XCTAssertEqualObjects(e.domain, ATaskTestErrorDomain);
        [ex1 fulfill];
    });

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_14_fail_returns_value {
    id ex1 = [self expectationWithDescription:@""];
    
    [ATask taskWithValue:@1].then(^{
        return [NSError errorWithDomain:@"a" code:1 userInfo:nil];
    }).catch(^(NSError *e){
        XCTAssertEqual(e.code, 1);
        return @2;
    }).then(^(id o){
        XCTAssertEqualObjects(o, @2);
        [ex1 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_15_fail_returns_task {
    id ex1 = [self expectationWithDescription:@""];
    ATTask(@10).then(^{
        return dummy();
    }).catch(^{
        return fulfillLater().then(^{
            return @123;
        });
    }).then(^(id o){
        XCTAssertEqualObjects(o, @123);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_16_add_another_fail_to_already_rejected {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    
    ATResolver resolve;
    ATask *task = [[ATask alloc] initWithResolver:&resolve];
    task.then(^{
        XCTFail();
    }).catch(^(NSError *e){
        XCTAssertEqualObjects(e.localizedDescription, @"23");
        [ex1 fulfill];
    });
    
    resolve(ATaskResultRejected, dummyWithCode(23));
    
    task.then(^{
        XCTFail();
    }).catch(^(NSError *e){
        XCTAssertEqualObjects(e.localizedDescription, @"23");
        [ex2 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_17_then_plus_deferred_plus_GCD {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    id ex3 = [self expectationWithDescription:@""];
    
    fulfillLater().then(^(id o){
        [ex1 fulfill];
        return fulfillLater().then(^{
            return @YES;
        });
    }).then(^(id o){
        XCTAssertEqualObjects(@YES, o);
        [ex2 fulfill];
    }).then(^(id o){
        XCTAssertNil(o);
        [ex3 fulfill];
    }).catch(^{
        XCTFail();
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_18_task_then_task_fail_task_fail {
    id ex1 = [self expectationWithDescription:@""];
    fulfillLater().then(^{
        return fulfillLater().then(^{
            return dummy();
        }).catch(^{
            return fulfillLater().then(^{
                return dummy();
            });
        });
    }).then(^{
        XCTFail();
    }).catch(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_19_eat_failure {
    id ex1 = [self expectationWithDescription:@""];
    fulfillLater().then(^{
        return dummy();
    }).catch(^{
        return @YES;
    }).then(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_20_deferred_rejected_catch_task {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    rejectLater().catch(^{
        [ex1 fulfill];
        return fulfillLater();
    }).then(^(id o){
        [ex2 fulfill];
    }).catch(^{
        XCTFail();
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_21_deferred_rejected_catch_task {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    
    rejectLater().catch(^{
        [ex1 fulfill];
        return fulfillLater().then(^{
            return dummy();
        });
    }).then(^{
        XCTFail(@"1");
    }).catch(^(NSError *error){
        [ex2 fulfill];
    }).catch(^{
        XCTFail(@"2");
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_22_dispatch_returns_pending_task {
    id ex1 = [self expectationWithDescription:@""];
    dispatch_task(^{
        return fulfillLater();
    }).then(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_23_dispatch_returns_task {
    id ex1 = [self expectationWithDescription:@""];
    dispatch_task(^{
        return [ATask taskWithValue:@1];
    }).then(^(id o){
        XCTAssertEqualObjects(o, @1);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_24_return_primitive {
    id ex1 = [self expectationWithDescription:@""];
    __block void (^fulfiller)(ATaskResult, id) = nil;
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        fulfiller = resolve;
    }].then(^(id o){
        XCTAssertEqualObjects(o, @32);
        return 3;
    }).then(^(id o){
        XCTAssertEqualObjects(@3, o);
        [ex1 fulfill];
    });
    fulfiller(ATaskResultFulfilled, @32);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_25_return_nil {
    id ex1 = [self expectationWithDescription:@""];
    ATTask(ATaskResultFulfilled, @1).then(^(id o){
        XCTAssertEqualObjects(o, @1);
        return nil;
    }).then(^{
        return nil;
    }).then(^(id o){
        XCTAssertNil(o);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_26_return_nil {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    
    [ATask taskWithValue:@"HI"].then(^(id o){
        XCTAssertEqualObjects(o, @"HI");
        [ex1 fulfill];
        return nil;
    }).then(^{
        return nil;
    }).then(^{
        [ex2 fulfill];
        return nil;
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_27_task_with_value_nil {
    id ex1 = [self expectationWithDescription:@""];
    
    [ATask taskWithValue:nil].then(^(id o){
        XCTAssertNil(o);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_28 {
    id ex1 = [self expectationWithDescription:@""];
    
    [ATask taskWithValue:@1].then(^{
        return fulfillLater();
    }).then(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_29_return_task_from_itself {
    id ex1 = [self expectationWithDescription:@""];
    
    ATask *p = fulfillLater().then(^{ return @1; });
    p.then(^{
        return p;
    }).then(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_30_reseal {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        resolve(ATaskResultFulfilled, @123);
        resolve(ATaskResultFulfilled, @234);
    }].then(^(id o){
        XCTAssertEqualObjects(o, @123);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_31_test_then_on {
    id ex1 = [self expectationWithDescription:@""];
    
    dispatch_queue_t q1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_queue_t q2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [ATask taskWithValue:@1].thenOn(q1, ^{
        XCTAssertFalse([NSThread isMainThread]);
        return dispatch_get_current_queue();
    }).thenOn(q2, ^(id q){
        XCTAssertFalse([NSThread isMainThread]);
        XCTAssertNotEqualObjects(q, dispatch_get_current_queue());
        [ex1 fulfill];
    });
#pragma clang diagnostic pop
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_32_finally_plus {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@1].then(^{
        return @1;
    }).ensure(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_33_finally_negative {
    @autoreleasepool {
        id ex1 = [self expectationWithDescription:@"always"];
        id ex2 = [self expectationWithDescription:@"errorUnhandler"];

        [ATask taskWithValue:@1].then(^{
            return dummy();
        }).ensure(^{
            [ex1 fulfill];
        }).catch(^(NSError *err){
            XCTAssertEqualObjects(err.domain, ATaskTestErrorDomain);
            [ex2 fulfill];
        });
    }
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_34_finally_negative_later {
    id ex1 = [self expectationWithDescription:@""];
    __block int x = 0;
    [ATask taskWithValue:@1].then(^{
        XCTAssertEqual(++x, 1);
        return dummy();
    }).catch(^{
        XCTAssertEqual(++x, 2);
    }).then(^{
        XCTAssertEqual(++x, 3);
    }).ensure(^{
        XCTAssertEqual(++x, 4);
        [ex1 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_35_fulfill_with_pending_task {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        resolve(ATaskResultFulfilled, fulfillLater().then(^{ return @"HI"; }));
    }].then(^(id hi){
        XCTAssertEqualObjects(hi, @"HI");
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_36_fulfill_with_fulfilled_task {
    id ex1 = [self expectationWithDescription:@""];
    
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        resolve(ATaskResultFulfilled, [ATask taskWithValue:@1]);
    }].then(^(id o){
        XCTAssertEqualObjects(o, @1);
        [ex1 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_37_fulfill_with_rejected_task {  //NEEDEDanypr
    id ex1 = [self expectationWithDescription:@""];
    fulfillLater().then(^{
        return [ATask taskWithResolverBlock:^(ATResolver resolve) {
            resolve(ATaskResultRejected, dummy());
        }];
    }).catch(^(NSError *err){
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_38_return_rejected_task {
    id ex1 = [self expectationWithDescription:@""];
    fulfillLater().then(^{
        return @1;
    }).then(^{
        return [ATask taskWithValue:dummy()];
    }).catch(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_39_reject_with_rejected_task {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        id err = [NSError errorWithDomain:@"a" code:123 userInfo:nil];
        resolve(ATaskResultRejected, [ATask taskWithValue:err]);
    }].catch(^(NSError *err){
        XCTAssertEqual(err.code, 123);
        [ex1 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_40_just_finally {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = fulfillLater().then(^{
        return nil;
    }).ensure(^{
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
    id ex2 = [self expectationWithDescription:@""];
    task.ensure(^{
        [ex2 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_41_catch_in_background {
    id ex1 = [self expectationWithDescription:@""];
    
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        id err = [NSError errorWithDomain:@"a" code:123 userInfo:nil];
        resolve(ATaskResultRejected, err);
    }].catchOn(dispatch_get_global_queue(0, 0), ^(NSError *err){
        XCTAssertEqual(err.code, 123);
        XCTAssertFalse([NSThread isMainThread]);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_42_catch_on_specific_queue {
    id ex1 = [self expectationWithDescription:@""];
    NSString *expectedQueueName = @"specific queue 123";
    dispatch_queue_t q = dispatch_queue_create(expectedQueueName.UTF8String, DISPATCH_QUEUE_SERIAL);
    
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        id err = [NSError errorWithDomain:@"a" code:123 userInfo:nil];
        resolve(ATaskResultRejected, err);
    }].catchOn(q, ^(NSError *err){
        XCTAssertEqual(err.code, 123);
        XCTAssertFalse([NSThread isMainThread]);
        NSString *currentQueueName = [NSString stringWithFormat:@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
        XCTAssertEqualObjects(expectedQueueName, currentQueueName);
        [ex1 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_43_wait_for_value {
    id o = [ATask taskWithResolverBlock:^(ATResolver resolve) {
        resolve(ATaskResultFulfilled, @1);
    }].wait;
    XCTAssertEqualObjects(o, @1);
}

- (void)test_62_wait_for_error {
    NSError* err = [ATask taskWithResolverBlock:^(ATResolver resolve) {
        resolve(ATaskResultRejected, [NSError errorWithDomain:@"a" code:123 userInfo:nil]);
    }].wait;
    XCTAssertEqual(err.code, 123);
}

#pragma mark - ATask+FWD
///=============================================================================
/// @name ATask+FWD
///=============================================================================

- (void)test_race {
    id ex = [self expectationWithDescription:@""];
    id p = ATAfter(0.1).then(^{ return @2; });
    ATRace(@[ATAfter(0.2), ATAfter(0.5), p]).then(^(id obj){
        XCTAssertEqual(2, [obj integerValue]);
        [ex fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testInBackground {
    id ex = [self expectationWithDescription:@""];
    ATAfter(0.1).thenOn(dispatch_get_global_queue(0, 0), ^{ [ex fulfill]; });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testEnsureOn {
    id ex = [self expectationWithDescription:@""];
    ATAfter(0.1).ensureOn(dispatch_get_global_queue(0, 0), ^{ [ex fulfill]; });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

static NSHashTable *errorArray;

- (void)setUp {
    [super setUp];
    errorArray = [NSHashTable weakObjectsHashTable];

}

- (void)testErrorLeaks {
    id ex1 = [self expectationWithDescription:@""];
    NSError *error = dummyWithCode(1001);
    [errorArray addObject:error];
    [ATask taskWithValue:error]
    .then(^{
        XCTFail();
    }).catch(^(NSError *e){
        XCTAssertEqual(e.localizedDescription.intValue, 1001);
    }).then(^{
        NSError *err = dummyWithCode(1002);
        [errorArray addObject:err];
        return err;
    }).catch(^(NSError *e){
        XCTAssertEqual(e.localizedDescription.intValue, 1002);
    }).then(^{
        NSError *err = dummyWithCode(1003);
        [errorArray addObject:err];
        return ATTask(err);
    }).catch(^(NSError *e){
        XCTAssertEqual(e.localizedDescription.intValue, 1003);
        NSError *err = dummyWithCode(1004);
        [errorArray addObject:err];
        return err;
    }).catch(^(NSError *e){
        XCTAssertEqual(e.localizedDescription.intValue, 1004);
    }).then(^{
        NSError *err = dummyWithCode(1005);
        [errorArray addObject:err];
//        // throw will lead to leak, if not use complie flag with "-fobjc-arc-exceptions"
//        @throw err;
    }).catch(^(NSError *e){
        XCTAssertEqual(e.localizedDescription.intValue, 1005);
    }).ensure(^{
        [ex1 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - ATuple
///=============================================================================
/// @name ATuple
///=============================================================================

- (void)test_atuple_access_extra_elements {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithResolverBlock:^(ATResolver resolve) {
        resolve(ATaskResultFulfilled, ATuple(@1));
    }].then(^(id o, id m, id n){
        XCTAssertNil(m, @"Accessing extra elements should not crash");
        XCTAssertNil(n, @"Accessing extra elements should not crash");
        XCTAssertEqualObjects(o, @1);
        [ex1 fulfill];
    });

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_atuple_then_manifold {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@0].then(^{
        return ATuple(@1, @2, @3);
    }).then(^(id o1, id o2, id o3){
        XCTAssertEqualObjects(o1, @1);
        XCTAssertEqualObjects(o2, @2);
        XCTAssertEqualObjects(o3, @3);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_atuple_then_manifold_with_nil {
    id ex1 = [self expectationWithDescription:@""];
    [ATask taskWithValue:@0].then(^{
        return ATuple(@1, nil, @3);
    }).then(^(id o1, id o2, id o3){
        XCTAssertEqualObjects(o1, @1);
        XCTAssertEqualObjects(o2, nil);
        XCTAssertEqualObjects(o3, @3);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_65_manifold_fulfill_value {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:@1].then(^{
        return ATuple(@123, @2);
    });
    task.then(^(id a, id b){
        XCTAssertNotNil(a);
        XCTAssertNotNil(b);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqualObjects(task.value, @123);
}

- (void)test_atuple_2 {
    id ex1 = [self expectationWithDescription:@""];
    ATAfter(0.02).then(^{
        return ATuple(@1, @2);
    }).then(^(id a, id b){
        XCTAssertEqualObjects(a, @1);
        XCTAssertEqualObjects(b, @2);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Join
///=============================================================================
/// @name Join
///=============================================================================

- (void)test_join {
    XCTestExpectation *ex1 = [self expectationWithDescription:@""];
    __block void (^fulfiller)(ATaskResult, id) = nil;
    ATask *task = [ATask taskWithResolverBlock:^(ATResolver resolve) {
        fulfiller = resolve;
    }];
    ATJoin(@[
        [ATask taskWithValue:[NSError errorWithDomain:@"dom" code:1 userInfo:nil]],
        task,
        [ATask taskWithValue:[NSError errorWithDomain:@"dom" code:2 userInfo:nil]]
    ]).then(^{
        XCTFail();
    }).catch(^(NSArray *tasks){
        int cume = 0, cumv = 0;

        for (ATask *task in tasks) {
            if (task.rejected) {
                cume |= [task.value code];
            } else {
                cumv |= [task.value unsignedIntValue];
            }
        }
        XCTAssertTrue(cumv == 4);
        XCTAssertTrue(cume == 3);
        [ex1 fulfill];
    });
    fulfiller(ATaskResultFulfilled, @4);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_join_no_errors {
    XCTestExpectation *ex1 = [self expectationWithDescription:@""];
    ATJoin(@[[ATask taskWithValue:@1],
             [ATask taskWithValue:@2]
            ]).then(^(NSArray *values, id errors) {
        XCTAssertEqualObjects(values, (@[@1, @2]));
        XCTAssertNil(errors);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_join_no_success {
    XCTestExpectation *ex1 = [self expectationWithDescription:@""];
    ATJoin(@[[ATask taskWithValue:[NSError errorWithDomain:@"dom" code:1 userInfo:nil]],
             [ATask taskWithValue:[NSError errorWithDomain:@"dom" code:2 userInfo:nil]]
              ]).then(^{
        XCTFail();
    }).catch(^(NSArray *tasks){
        XCTAssertNotNil(tasks);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_join_fulfills_if_empty_input {
    XCTestExpectation *ex1 = [self expectationWithDescription:@""];
    ATJoin(@[]).then(^(id a, id b, id c){
        XCTAssertEqualObjects(@[], a);
        XCTAssertNil(b);
        XCTAssertNil(c);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_join_nil {
    NSArray *foo = nil;
    NSError *err = ATJoin(foo).value;
    XCTAssertEqual(err.code, 31);
}

#pragma mark - Hang
///=============================================================================
/// @name Hang
///=============================================================================

- (void)test_hang {
    __block int x = 0;
    id value = ATHang(ATAfter(0.02).then(^{ x++; return 1; }));
    XCTAssertEqual(x, 1);
    XCTAssertEqualObjects(value, @1);
}

#pragma mark - When
///=============================================================================
/// @name When
///=============================================================================

- (void)test_when_progress {
    id ex = [self expectationWithDescription:@""];
    XCTAssertNil([NSProgress currentProgress]);
    id p1 = ATAfter(0.01);
    id p2 = ATAfter(0.02);
    id p3 = ATAfter(0.03);
    id p4 = ATAfter(0.04);
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:1];
    [progress becomeCurrentWithPendingUnitCount:1];

    ATWhen(@[p1, p2, p3, p4]).then(^{
        XCTAssertEqual(progress.completedUnitCount, 1);
        [ex fulfill];
    });
    [progress resignCurrent];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_progress_doesnot_exceed_100_percent {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    XCTAssertNil([NSProgress currentProgress]);

    id p1 = ATAfter(0.01);
    id p2 = ATAfter(0.02).then(^{ return [NSError errorWithDomain:@"a" code:1 userInfo:nil]; });
    id p3 = ATAfter(0.03);
    id p4 = ATAfter(0.04);

    id tasks = @[p1, p2, p3, p4];
    NSProgress *progress = [NSProgress progressWithTotalUnitCount:1];
    [progress becomeCurrentWithPendingUnitCount:1];

    ATWhen(tasks).catch(^{
        [ex2 fulfill];
    });
    [progress resignCurrent];
    ATJoin(tasks).catch(^{
        XCTAssertLessThanOrEqual(1, progress.fractionCompleted);
        XCTAssertEqual(progress.completedUnitCount, 1);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_tuple {
    id ex = [self expectationWithDescription:@""];
    id p1 = dispatch_task(^{ return ATuple(@1, @2); });
    id p2 = dispatch_task(^{});
    ATWhen(@[p1, p2]).then(^(NSArray *results){
        XCTAssertEqualObjects(results[0], @1);
        XCTAssertEqualObjects(results[1], [NSNull null]);
        [ex fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_all_dictionary {
    id ex1 = [self expectationWithDescription:@""];
    id tasks = @{
          @1: @2,
          @2: @"abc",
        @"a": ATAfter(0.1).then(^{ return @"HI"; })
    };
    ATWhen(tasks).then(^(NSDictionary *dict){
        XCTAssertEqual(dict.count, 3ul);
        XCTAssertEqualObjects(dict[@1], @2);
        XCTAssertEqualObjects(dict[@2], @"abc");
        XCTAssertEqualObjects(dict[@"a"], @"HI");
        [ex1 fulfill];
    });

    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (void)test_when_empty_array {
    id ex1 = [self expectationWithDescription:@""];

    ATWhen(@[]).then(^(NSArray *array){
        XCTAssertEqual(array.count, 0ul);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_equal {
    id ex1 = [self expectationWithDescription:@""];

    id a = ATAfter(0.02).then(^{ return @345; });
    id b = ATAfter(0.03).then(^{ return @345; });
    ATWhen(@[a, b]).then(^(NSArray *objs){
        XCTAssertEqual(objs.count, 2ul);
        XCTAssertEqualObjects(objs[0], objs[1]);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_recursive {
    id domain = @"sdjhfg";

    id ex1 = [self expectationWithDescription:@""];
    id a = ATAfter(0.03).then(^{
        return [NSError errorWithDomain:domain code:123 userInfo:nil];
    });
    id b = ATAfter(0.02);
    id c = ATWhen(@[a, b]);
    ATWhen(c).then(^{
        XCTFail();
    }).catch(^(NSError *e){
        XCTAssertEqualObjects(e.domain, domain);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_already_resolved_and_bubble {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    ATResolver resolve;
    ATask *task = [[ATask alloc] initWithResolver:&resolve];
    task.then(^{
        XCTFail();
    }).catch(^(NSError *e){
        [ex1 fulfill];
    });
    resolve(ATaskResultRejected, [NSError errorWithDomain:@"a" code:1 userInfo:nil]);
    ATWhen(task).then(^{
        XCTFail();
    }).catch(^{
        [ex2 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_some_edge_case {
    id ex1 = [self expectationWithDescription:@""];
    id a = ATAfter(0.02).catch(^{});
    id b = ATAfter(0.03);
    ATWhen(@[a, b]).then(^(NSArray *objs){
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_nil {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:@"35"].then(^{ return nil; });
    ATWhen(@[ATAfter(0.02).then(^{ return @1; }), [ATask taskWithValue:nil], task]).then(^(NSArray *results){
        XCTAssertEqual(results.count, 3ul);
        XCTAssertEqualObjects(results[1], [NSNull null]);
        [ex1 fulfill];
    }).catch(^(NSError *err){
        abort();
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_with_some_values {
    id ex1 = [self expectationWithDescription:@""];
    id p = ATAfter(0.02);
    id v = @1;
    ATWhen(@[p, v]).then(^(NSArray *aa){
        XCTAssertEqual(aa.count, 2ul);
        XCTAssertEqualObjects(aa[1], @1);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_with_all_values {
    id ex1 = [self expectationWithDescription:@""];
    ATWhen(@[@1, @2]).then(^(NSArray *aa){
        XCTAssertEqualObjects(aa[0], @1);
        XCTAssertEqualObjects(aa[1], @2);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_with_repeated_tasks {
    id ex1 = [self expectationWithDescription:@""];

    id p = ATAfter(0.02);
    id v = @1;
    ATWhen(@[p, v, p, v]).then(^(NSArray *aa){
        XCTAssertEqual(aa.count, 4ul);
        XCTAssertEqualObjects(aa[1], @1);
        XCTAssertEqualObjects(aa[3], @1);
        [ex1 fulfill];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_45_when_which_returns_void {
    id ex1 = [self expectationWithDescription:@""];
    ATask *task = [ATask taskWithValue:@1].then(^{});
    ATWhen(@[task, [ATask taskWithValue:@1]]).then(^(NSArray *stuff){
        XCTAssertEqual(stuff.count, 2ul);
        XCTAssertEqualObjects(stuff[0], [NSNull null]);
        [ex1 fulfill];
    });

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_when_nil_2 {
    NSArray *foo = nil;
    NSError *err = ATWhen(foo).value;
    XCTAssertEqualObjects(err.domain, ATaskTestErrorDomain);
    XCTAssertEqual(err.code, 31);
}

- (void)test_when_bad_input {
    id foo = @"a";
    XCTAssertEqual(ATWhen(foo).value, foo);
}

- (void)test_properties {
    XCTAssertEqualObjects([ATask taskWithValue:@1].value, @1);
    XCTAssertEqualObjects([[ATask taskWithValue:dummyWithCode(2)].value localizedDescription], @"2");
    XCTAssertNil([ATask taskWithResolverBlock:^(id a){}].value);
    XCTAssertTrue([ATask taskWithResolverBlock:^(id a){}].pending);
    XCTAssertFalse([ATask taskWithValue:@1].pending);
    XCTAssertTrue([ATask taskWithValue:@1].fulfilled);
    XCTAssertFalse([ATask taskWithValue:@1].rejected);
}

- (void)test_taskWithValue {
    XCTAssertEqual([ATask taskWithValue:@1].value, @1);
    XCTAssertEqualObjects([[ATask taskWithValue:dummyWithCode(2)].value localizedDescription], @"2");
    XCTAssertEqual([ATask taskWithValue:[ATask taskWithValue:@1]].value, @1);
}


#pragma mark - Process
///=============================================================================
/// @name Process
///=============================================================================

typedef NS_ENUM(NSUInteger, ATaskTest) {
    ATaskTestOne = 0,
    ATaskTestTwo,
    ATaskTestThree
};

- (void)test_process {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    ATResolver resolve;
    ATask *task = [[ATask alloc] initWithResolver:&resolve];
    task.process(^(ATaskTest type, id value){
        XCTAssertEqual(type, ATaskTestThree);
        XCTAssertEqualObjects(value, @23);
        [ex1 fulfill];
    }).then(^{
        XCTFail();
    }).then(^{
        XCTFail();
    }).catch(^(NSError *e){
        XCTAssertEqualObjects(e.localizedDescription, @"23");
        [ex2 fulfill];
    });
    resolve(ATaskResultProcess, ATuple(@(ATaskTestThree), @23));
    resolve(ATaskResultRejected, dummyWithCode(23));
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_process_extra {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    ATResolver resolve;
    ATask *task = [[ATask alloc] initWithResolver:&resolve];
    task.then(^(NSNumber *t) {
        [ex1 fulfill];
        XCTAssertEqual(t.intValue, 1);
    });
    task.process(^(ATaskTest type){
        XCTAssertEqual(type, ATaskTestThree);
        [ex2 fulfill];
    }).catch(^(ATask *t) {
        XCTFail();
    });
    resolve(ATaskResultProcess, ATuple(@(ATaskTestThree), @23));
    resolve(ATaskResultFulfilled, @1);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_process_extra_rejected {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    ATResolver resolve;
    ATask *task = [[ATask alloc] initWithResolver:&resolve];
    task.then(^(NSNumber *t) {
        XCTFail();
    }).process(^(ATaskTest type){
        XCTFail();
    });
    task.process(^(ATaskTest type){
        XCTAssertEqual(type, ATaskTestThree);
        [ex2 fulfill];
    }).catch(^(NSNumber *t) {
        [ex1 fulfill];
        XCTAssertEqual(t.intValue, 1);
    });
    resolve(ATaskResultRejected, @1);
    resolve(ATaskResultProcess, ATuple(@(ATaskTestThree), @23));
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_process_block_params {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    ATResolver resolve;
    ATask *task = [[ATask alloc] initWithResolver:&resolve];
    task.then(^(NSNumber *t) {
        [ex1 fulfill];
        XCTAssertEqual(t.intValue, 1);
    });
    task.process(^(BOOL type){
        XCTAssertTrue(type);
        [ex2 fulfill];
    }).catch(^(ATask *t) {
        XCTFail();
    });
    resolve(ATaskResultProcess, ATuple(@YES, @23));
    resolve(ATaskResultFulfilled, @1);
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_atasksource_process {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    ATaskSource *tcs = [ATaskSource source];
    tcs.task.process(^(BOOL type){
        XCTAssertTrue(type);
        [ex2 fulfill];
    }).then(^(NSNumber *t) {
        [ex1 fulfill];
        XCTAssertEqual(t.intValue, 1);
    });
    [tcs setProcess:ATuple(@YES, @23)];
    [tcs setResult:@1];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_atasksource_process_task {
    id ex1 = [self expectationWithDescription:@""];
    id ex2 = [self expectationWithDescription:@""];
    id ex3 = [self expectationWithDescription:@""];
    ATaskSource *tcs = [ATaskSource source];
    tcs.task.process(^(BOOL type, id value){
        XCTAssertTrue(type);
        [ex2 fulfill];
        return ATTask(value);
    }).then(^(NSNumber *t) {
        [ex1 fulfill];
        XCTAssertEqual(t.intValue, 1);
    });
    ATask *task = [tcs setProcess:ATuple(@YES, @23)];
    task.then(^(NSInteger num) {
        XCTAssertEqual(num, 23);
        [ex3 fulfill];
    });
    [tcs setResult:@1];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


@end

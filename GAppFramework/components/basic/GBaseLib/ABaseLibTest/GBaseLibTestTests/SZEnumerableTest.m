//
//  SZEnumerableTest.m
//  ABaseLibTestTests
//
//  Created by guozhongda on 2019/12/2.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+Extend.h"

@interface SZEnumerableTest : XCTestCase

@end

@implementation SZEnumerableTest

#pragma mark - All Satisfy
///=============================================================================
/// @name All Satisfy
///=============================================================================

- (void)test_allsatisfy_array {
    NSArray *arr = @[@YES, @NO];
    BOOL satisfy = [arr allSatisfy:^BOOL(NSNumber *each) {
        return [each boolValue];
    }];
    XCTAssertTrue(!satisfy);
}

- (void)test_allsatisfy_dictionary {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3
    };
    BOOL satisfy = [dict allSatisfy:^BOOL(SZAssociation *as) {
        return [as.value integerValue] == [as.key integerValue];
    }];
    XCTAssertTrue(satisfy);
}

- (void)test_allsatisfy_number {
    NSNumber *num = @4;
    __block NSInteger sum = 0;
    BOOL satisfy = [num allSatisfy:^BOOL(NSNumber *each) {
        sum += [each integerValue];
        return each.integerValue >= 0;
    }];
    XCTAssertTrue(satisfy);
    XCTAssertTrue(sum==10);
}

- (void)test_allsatisfy_string {
    NSString *str = @"234";
    __block NSInteger sum = 0;
    BOOL satisfy = [str allSatisfy:^BOOL(NSString *each) {
        sum += [each integerValue];
        return each.integerValue >= 2;
    }];
    XCTAssertTrue(satisfy);
    XCTAssertTrue(sum==9);
}

- (void)test_allsatisfy_null {
    NSNull *null = [NSNull null];
    __block NSInteger sum = 0;
    BOOL satisfy = [null allSatisfy:^BOOL(NSString *each) {
        XCTFail();
        sum++;
        return nil;
    }];
    XCTAssertTrue(satisfy);
    XCTAssertTrue(sum==0);
}

#pragma mark - Any Satisfy
///=============================================================================
/// @name Any Satisfy
///=============================================================================

- (void)test_anysatisfy_array {
    NSArray *arr = @[@YES, @NO];
    BOOL satisfy = [arr anySatisfy:^BOOL(NSNumber *each) {
        return [each boolValue];
    }];
    XCTAssertTrue(satisfy);
}

- (void)test_anysatisfy_dictionary {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3
    };
    BOOL satisfy = [dict anySatisfy:^BOOL(SZAssociation *as) {
        return [as.value integerValue] >= 3;
    }];
    XCTAssertTrue(satisfy);
}

- (void)test_anysatisfy_number {
    NSNumber *num = @4;
    __block NSInteger sum = 0;
    BOOL satisfy = [num anySatisfy:^BOOL(NSNumber *each) {
        sum += [each integerValue];
        return each.integerValue >= 4;
    }];
    XCTAssertTrue(satisfy);
    XCTAssertTrue(sum==10);
}

- (void)test_anysatisfy_string {
    NSString *str = @"234";
    __block NSInteger sum = 0;
    BOOL satisfy = [str anySatisfy:^BOOL(NSString *each) {
        sum += [each integerValue];
        return each.integerValue >= 4;
    }];
    XCTAssertTrue(satisfy);
    XCTAssertTrue(sum==9);
}

- (void)test_anysatisfy_null {
    NSNull *null = [NSNull null];
    __block NSInteger sum = 0;
    BOOL satisfy = [null anySatisfy:^BOOL(NSString *each) {
        XCTFail();
        sum++;
        return nil;
    }];
    XCTAssertTrue(!satisfy);
    XCTAssertTrue(sum==0);
}

#pragma mark - Detect
///=============================================================================
/// @name Detect
///=============================================================================

- (void)test_detect_array {
    NSArray *arr = @[@YES, @NO];
    id obj = [arr detect:^BOOL(NSNumber *each) {
        return ![each boolValue];
    }];
    XCTAssertEqualObjects(arr[1], obj);
    XCTAssertTrue(![obj boolValue]);
}

- (void)test_detect_dictionary {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3
    };
    SZAssociation *as = [dict detect:^BOOL(SZAssociation *as) {
        return [as.value integerValue] >= 3;
    }];
    XCTAssertTrue([as.value integerValue]==3);
}

- (void)test_detect_number {
    NSNumber *num = @4;
    __block NSInteger sum = 0;
    id obj = [num detect:^BOOL(NSNumber *each) {
        sum += [each integerValue];
        return each.integerValue >= 3;
    }];
    XCTAssertEqualObjects(obj, @3);
    XCTAssertTrue(sum==6);
}

- (void)test_detect_string {
    NSString *str = @"234";
    __block NSInteger sum = 0;
    id obj = [str detect:^BOOL(NSString *each) {
        sum += [each integerValue];
        return each.integerValue >= 3;
    }];
    XCTAssertEqualObjects(obj, @"3");
    XCTAssertTrue(sum==5);
}

- (void)test_detect_null {
    NSNull *null = [NSNull null];
    __block NSInteger sum = 0;
    id obj = [null detect:^BOOL(NSString *each) {
        XCTFail();
        sum++;
        return nil;
    }];
    XCTAssertNil(obj);
    XCTAssertTrue(sum==0);
}

#pragma mark - Map
///=============================================================================
/// @name Map
///=============================================================================

- (void)test_map_array {
    NSArray *arr = @[@YES, @NO];
    NSArray *new = [arr map:^id(NSNumber *each) {
        return [each boolValue] ? @2 : @3;
    }];
    XCTAssertEqualObjects(new[0], @2);
    XCTAssertEqualObjects(new[1], @3);
}

- (void)test_map_dictionary_value {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3};
    NSDictionary *new = [dict map:^id(SZAssociation *each) {
        each.value = @([each.value integerValue] * 3);
        return each;
    }];
    XCTAssertEqualObjects(new[@"1"], @3);
    XCTAssertEqualObjects(new[@"2"], @6);
    XCTAssertEqualObjects(new[@"3"], @9);
}

- (void)test_map_dictionary_key {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3};
    NSDictionary *new = [dict map:^id(SZAssociation *each) {
        each.key = [@([each.value integerValue] * 3) stringValue];
        return each;
    }];
    XCTAssertEqualObjects(new[@"3"], @1);
    XCTAssertEqualObjects(new[@"6"], @2);
    XCTAssertEqualObjects(new[@"9"], @3);
    XCTAssertEqualObjects(dict[@"1"], @1);
    XCTAssertEqualObjects(dict[@"2"], @2);
    XCTAssertEqualObjects(dict[@"3"], @3);
}

- (void)test_map_number {
    NSNumber *num = @4;
    NSArray *arr = [num map:^id(id each) {
        return each;
    }];
    XCTAssertEqualObjects(arr[0], @0);
    XCTAssertEqualObjects(arr[4], @4);
}

- (void)test_map_szinterval {
    SZInterval *intv = [[SZInterval alloc] initWithFrom:3 to:9 by:2];
    __block NSInteger sum = 0;
    NSArray *arr = [intv map:^id(NSNumber *each) {
        sum += [each integerValue];
        return @(each.integerValue * 3);
    }];
    XCTAssertTrue(sum==(3+5+7+9));
    XCTAssertEqualObjects(arr[0], @9);
    XCTAssertEqualObjects(arr[1], @15);
    XCTAssertEqualObjects(arr[2], @21);
    XCTAssertEqualObjects(arr[3], @27);
}

- (void)test_map_string {
    NSString *str = @"234";
    NSString *obj = [str map:^id(NSString *each) {
        return [NSString stringWithFormat:@"%@i", each];
    }];
    XCTAssertEqualObjects(obj, @"2i3i4i");
}

- (void)test_map_null {
    NSNull *null = [NSNull null];
    __block NSInteger sum = 0;
    id obj = [null map:^id(id each) {
        sum++;
        return nil;
    }];
    XCTAssertNil(obj);
    XCTAssertTrue(sum==1);
}

#pragma mark - Filter
///=============================================================================
/// @name Filter
///=============================================================================

- (void)test_filter_array {
    NSArray *arr = @[@YES, @NO];
    NSArray *new = [arr filter:^BOOL(id each) {
        return [each boolValue];
    }];
    XCTAssertEqualObjects(new[0], @YES);
    XCTAssertTrue(new.count==1);
    XCTAssertTrue(arr.count==2);
}

- (void)test_filter_dictionary_value {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3};
    NSDictionary *new = [dict filter:^BOOL(SZAssociation *each) {
        return [each.value integerValue] >= 2;
    }];
    XCTAssertTrue(new.allKeys.count==2);
    XCTAssertEqualObjects(new[@"2"], @2);
    XCTAssertEqualObjects(new[@"3"], @3);
}

- (void)test_filter_dictionary_key {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3};
    NSDictionary *new = [dict filter:^BOOL(SZAssociation *each) {
        return [each.key integerValue] >= 2;
    }];
    XCTAssertTrue(new.allKeys.count==2);
    XCTAssertEqualObjects(new[@"2"], @2);
    XCTAssertEqualObjects(new[@"3"], @3);
}

- (void)test_filter_number {
    NSNumber *num = @4;
    NSArray *arr = [num filter:^BOOL(NSNumber *each) {
        return each.integerValue % 2 == 0;
    }];
    XCTAssertTrue(arr.count==3);
    XCTAssertEqualObjects(arr[0], @0);
    XCTAssertEqualObjects(arr[1], @2);
    XCTAssertEqualObjects(arr[2], @4);
}

- (void)test_filter_szinterval {
    SZInterval *intv = [[SZInterval alloc] initWithFrom:3 to:9 by:2];
    NSArray *arr = [intv filter:^BOOL(NSNumber *each) {
        return each.integerValue == 3 || each.integerValue == 7;
    }];
    XCTAssertTrue(arr.count == 2);
    XCTAssertEqualObjects(arr[0], @3);
    XCTAssertEqualObjects(arr[1], @7);
}

- (void)test_filter_string {
    NSString *str = @"234";
    NSString *obj = [str filter:^BOOL(NSString *each) {
        return each.integerValue % 2 == 0;
    }];
    XCTAssertEqualObjects(obj, @"24");
}

- (void)test_filter_null {
    NSNull *null = [NSNull null];
    __block NSInteger sum = 0;
    id obj = [null map:^id(id each) {
        sum++;
        return nil;
    }];
    XCTAssertNil(obj);
    XCTAssertTrue(sum==1);
}

#pragma mark - Reduce
///=============================================================================
/// @name Reduce
///=============================================================================

- (void)test_reduce_array {
    NSArray *arr = @[@3, @4];
    id result = [arr reduce:^id(id acc, id each) {
        return @([acc integerValue] + [each integerValue]);
    }];
    XCTAssertEqualObjects(result, @7);
}

- (void)test_reduce_dictionary_value {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3};
    id result = [dict reduce:@3 block:^id(NSNumber *acc, SZAssociation *each) {
        return @([acc integerValue] + [each.value integerValue]);
    }];
    XCTAssertEqualObjects(result, @9);
}

- (void)test_reduce_dictionary_key {
    NSDictionary *dict = @{@"1":@1,
                           @"2":@2,
                           @"3":@3};
    id result = [dict reduce:@"" block:^id(NSNumber *acc, SZAssociation *each) {
        return [NSString stringWithFormat:@"%@%@", acc, each.key];
    }];
    XCTAssertEqualObjects(result, @"123");
}

- (void)test_reduce_number {
    NSNumber *num = @4;
    id result = [num reduce:@"" block:^id(id acc, id each) {
        return [NSString stringWithFormat:@"%@%@", acc, each];
    }];
    XCTAssertEqualObjects(result, @"01234");
}

- (void)test_reduce_szinterval {
    SZInterval *intv = [[SZInterval alloc] initWithFrom:3 to:9 by:2];
    id result = [intv reduce:@"" block:^id(id acc, id each) {
        return [NSString stringWithFormat:@"%@%@", acc, each];
    }];
    XCTAssertEqualObjects(result, @"3579");
}

- (void)test_reduce_string {
    NSString *str = @"234";
    id result = [str reduce:@"3" block:^id(id acc, id each) {
        return [NSString stringWithFormat:@"%@%@", acc, each];
    }];
    XCTAssertEqualObjects(result, @"3234");
}

#pragma mark - Each
///=============================================================================
/// @name Each
///=============================================================================

- (void)test_each_array {
    NSArray *arr = @[@3, @4];
    __block NSInteger sum = 0;
    [arr each:^(id each, NSUInteger idx, BOOL *stop) {
        sum += [each integerValue];
    }];
    XCTAssertTrue(sum==7);
}

- (void)test_each_array_stop {
    NSArray *arr = @[@3, @4];
    __block NSInteger sum = 0;
    [arr each:^(id each, NSUInteger idx, BOOL *stop) {
        sum += [each integerValue];
        if (sum == 3) *stop = YES;
    }];
    XCTAssertTrue(sum==3);
}

- (void)test_each_separate_array {
    NSArray *arr = @[@3, @4];
    __block NSInteger sum = 0;
    [arr each:^(id each, NSUInteger idx, BOOL *stop) {
        sum += [each integerValue];
    } separate:^{
        sum += 3;
    }];
    XCTAssertTrue(sum==10);
}


- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

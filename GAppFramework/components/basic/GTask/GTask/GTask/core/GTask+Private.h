//
//  GTask+Private.h
//  GTask
//
//  Created by iOS_Developer_G on 2019/11/25.
//  Copyright © 2019 GCompany. All rights reserved.
//


typedef NS_ENUM(NSUInteger, _GTaskStatus) {
    _GTaskStatusPending = 0,
    _GTaskStatusFulfilled,
    _GTaskStatusRejected,
    _GTaskStatusCancel
};

@interface GTask (Private)
- (void)pipe:(void (^)(_GTaskStatus, id))block;
@end

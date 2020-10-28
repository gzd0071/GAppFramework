//
//  DMAWidget.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/5/13.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMAWidget.h"
#import <GBaseLib/GConvenient.h>
#import <DMUILib/DMAlertActions.h>
#import <YYKit/NSObject+YYModel.h>
#import <DMUILib/GHud.h>

@interface DMAWidgetModel : NSObject
///>  
@property (nonatomic, copy) NSString *info;
@end

@implementation DMAWidgetModel
@end


@implementation DMAWidget

+ (GTask *)toast:(NSDictionary *)args {
    DMAWidgetModel *model = [DMAWidgetModel modelWithJSON:args];
    if (!model.info || model.info.length == 0) return nil;
    
    NSString *trimString = [model.info stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimString.length == 0) return nil;
    
    [GHud toast:trimString];
    return nil;
}

#pragma mark - 弹框
///=============================================================================
/// @name Alert
///=============================================================================

///> 显示弹框 
+ (GTask *)showDialog:(NSDictionary *)args {
    GTaskSource *tcs = [GTaskSource source];
    DMAlertAction *cancel  = [DMAlertActions cancelAction:args[@"cancelBtn"]]
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status":@"0"}];
    });
    DMAlertAction *confirm = [DMAlertAction action].title(args[@"okBtn"])
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status":@"1"}];
    });
    id title   = [self handleAttr:args[@"titleAttribute"] string:args[@"title"]];
    id message = [self handleAttr:args[@"messageAttribute"] string:args[@"message"]];
    DMAlert *alert = [DMAlert alert].title(title).message(message);
    alert.addAction([DMAlertActions headerActionWithTypeName:args[@"imageName"]]);
    alert.addActions(@[cancel, confirm]).show(nil);
    return tcs.task;
}

+ (id)handleAttr:(NSString *)attrS string:(NSString *)string {
    if (!attrS || ![attrS isKindOfClass:NSArray.class]) return string;
    return string;
}

@end

//
//  DMSystemAlert.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/26.
//

#import "DMSystemAlert.h"

@interface DMSystemAlert()
///>
@property (nonatomic, strong) UIAlertController *alert;
@end

@implementation DMSystemAlert

- (void)dismiss:(BOOL)animate complete:(void (^)(void))block {
    [self.alert dismissViewControllerAnimated:animate completion:block];
}

+ (instancetype)show:(DMAlert *)alert vc:(UIViewController *)vc {
    DMSystemAlert *sa = [DMSystemAlert new];
    NSString *title = [alert.sTitle isKindOfClass:NSString.class] ? alert.sTitle : [alert.sTitle string];
    NSString *msg = [alert.sMessage isKindOfClass:NSString.class] ? alert.sMessage : [alert.sMessage string];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyle)alert.sStyle];
    if ([alert.sTitle isKindOfClass:NSAttributedString.class])   [ac setValue:alert.sTitle forKey:@"attributedTitle"];
    if ([alert.sMessage isKindOfClass:NSAttributedString.class]) [ac setValue:alert.sMessage forKey:@"attributedMessage"];
    [alert.actions enumerateObjectsUsingBlock:^(DMAlertAction *obj, NSUInteger idx, BOOL *stop) {
        [ac addAction:[self alertAction:obj]];
    }];
    if (!vc) vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:ac animated:YES completion:^{}];
    sa.alert = ac;
    return sa;
}

+ (UIAlertAction *)alertAction:(DMAlertAction *)each {
    id title = [each.sTitle isKindOfClass:NSAttributedString.class] ? [each.sTitle string] : each.sTitle;
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:(UIAlertActionStyle)each.sStyle handler:^(UIAlertAction *action) {
        if (each.block) each.block(each);
    }];
    if (each.sTitleColor) [action setValue:each.sTitleColor forKey:@"titleTextColor"];
    return action;
}
@end

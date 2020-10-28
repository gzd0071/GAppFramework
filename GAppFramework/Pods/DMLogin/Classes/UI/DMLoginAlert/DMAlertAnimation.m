//
//  DMDialogAnimation.m
//  test
//
//  Created by JasonLin on 2/19/16.
//

#import "DMAlertAnimation.h"
#import "DMLoginBaseAlertController.h"  
#import "DMLoginBaseAlertView.h"

@interface DMAlertAnimation()
@end

@implementation DMAlertAnimation

static const CGFloat kPresentAnimationDuration = 0.20f;
static const CGFloat kDismissAnimationDuration = 0.30f;

#pragma mark - Presenting Animation

- (void)executePresentingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    DMLoginBaseAlertController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height);
    toViewController.view.alpha = 0.0f;
    
    UIView * containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    
    switch (toViewController.preferredStyle) {
        case DMDialogControllerStyleCenter:
            [self presentingCenterStyle:transitionContext viewController:toViewController];
            break;
        case DMDialogControllerStyleBottom:
            [self presentingBottomStyle:transitionContext viewController:toViewController];
            break;
        default:
            [self presentingCenterStyle:transitionContext viewController:toViewController];
            break;
    }
}

- (void)presentingCenterStyle:(id<UIViewControllerContextTransitioning>)transitionContext viewController:(DMLoginBaseAlertController *)viewController {
    viewController.contentView.transform = CGAffineTransformMakeScale(1.15f, 1.15f);
    [UIView animateWithDuration:0.20 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewController.view.alpha = 1.0f;
        viewController.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished)
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)presentingBottomStyle:(id<UIViewControllerContextTransitioning>)transitionContext viewController:(DMLoginBaseAlertController *)viewController {
    [UIView animateWithDuration:0.30 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGSize windowSize = [UIScreen mainScreen].bounds.size;
        viewController.view.alpha = 1.0f;
        viewController.contentView.transform = CGAffineTransformIdentity;
        viewController.contentView.center = CGPointMake(viewController.contentView.center.x, windowSize.height - viewController.contentView.frame.size.height / 2);
    } completion:^(BOOL finished) {
        if (finished)
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

#pragma mark - Dismissing Animation

- (void)executeDismissingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    DMLoginBaseAlertController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height);
    
    switch (fromViewController.preferredStyle) {
        case DMDialogControllerStyleCenter:
            [self dismissingCenterStyle:transitionContext viewController:fromViewController];
            break;
        case DMDialogControllerStyleBottom:
            [self dismissingBottomStyle:transitionContext viewController:fromViewController];
            break;
        default:
            [self dismissingCenterStyle:transitionContext viewController:fromViewController];
            break;
    }
}

- (void)dismissingCenterStyle:(id<UIViewControllerContextTransitioning>)transitionContext viewController:(DMLoginBaseAlertController *)viewController {
    [UIView animateWithDuration:kDismissAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished)
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)dismissingBottomStyle:(id<UIViewControllerContextTransitioning>)transitionContext viewController:(DMLoginBaseAlertController *)viewController {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGSize windowSize = [UIScreen mainScreen].bounds.size;
        viewController.view.alpha = 0.0f;
        viewController.contentView.center = CGPointMake(viewController.contentView.center.x, windowSize.height + viewController.contentView.frame.size.height / 2);
    } completion:^(BOOL finished) {
        if (finished)
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[DMLoginBaseAlertController class]]) {
        return kPresentAnimationDuration;
    }
    return kDismissAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[DMLoginBaseAlertController class]]) {
        [self executePresentingAnimation:transitionContext];
    } else {
        [self executeDismissingAnimation:transitionContext];
    }
}

@end

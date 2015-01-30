//
// Created by Guillaume Lagorce on 18/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Animator.h"
#import <POP/POPSpringAnimation.h>


@implementation Animator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];

    toViewController.view.frame =
            ({
                CGRect frame = toViewController.view.frame;
                frame.origin.y = fromViewController.view.frame.size.height;
                frame;
            });

    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    animation.springSpeed = 20.f;
    animation.springBounciness = 20.f;
    animation.toValue = [NSValue valueWithCGRect:CGRectMake(0.f, 0.f, toViewController.view.frame.size.width, toViewController.view.frame.size.height)];
    [toViewController.view pop_addAnimation:animation forKey:@"toAnimFrame"];

    POPSpringAnimation *animation2 = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    animation2.springSpeed = 20.f;
    animation2.springBounciness = 20.f;
    animation2.toValue = [NSValue valueWithCGRect:CGRectMake(0.f, -fromViewController.view.frame.size.height, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    [fromViewController.view pop_addAnimation:animation2 forKey:@"toAnimFrame"];
    
    animation.completionBlock = ^(POPAnimation *animation, BOOL finished)
    {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    };
}

@end
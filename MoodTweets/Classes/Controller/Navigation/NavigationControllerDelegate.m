//
// Created by Guillaume Lagorce on 18/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationControllerDelegate.h"
#import "Animator.h"

@interface NavigationControllerDelegate () <UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) Animator* animator;

@end

@implementation NavigationControllerDelegate

- (void)awakeFromNib
{
    self.animator = [Animator new];
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    return self.animator;
}

@end
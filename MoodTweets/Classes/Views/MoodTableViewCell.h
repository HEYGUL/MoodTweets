//
// Created by Guillaume Lagorce on 31/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Tweet;

@interface MoodTableViewCell : UITableViewCell

@property(nonatomic, retain) Tweet *tweet;

- (void)displayMood;
- (void)rotateView;

@end
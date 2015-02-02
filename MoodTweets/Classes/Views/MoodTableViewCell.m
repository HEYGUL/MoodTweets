//
// Created by Guillaume Lagorce on 31/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "MoodTableViewCell.h"
#import "Tweet.h"
#import "Tweet+Helpers.h"
#import "POPSpringAnimation.h"
#import "SmileyView.h"
#import <FlatUIKit/FlatUIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface MoodTableViewCell ()

@property(nonatomic, weak) IBOutlet UIView *graphView;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;
@property(nonatomic, weak) IBOutlet SmileyView *smileyView;
@property(nonatomic, weak) IBOutlet UILabel *tweetTextLabel;

@end

@implementation MoodTableViewCell

/********************************************************************************/
#pragma mark - Birth & Death

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.graphView.layer.cornerRadius = 4.f;
    self.graphViewWidthConstraint.constant = 0.f;

    self.tweetTextLabel.alpha = 0.f;
    self.tweetTextLabel.layer.transform =  CATransform3DMakeRotation(M_PI, 1, 0, 0);
}

/********************************************************************************/
#pragma mark - Custom Setters/Getters

- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    [self refreshViewToShowLabel:NO animated:NO];
    self.graphView.backgroundColor = [self.tweet moodColor];
    self.tweetTextLabel.text = self.tweet.text;
    self.tweetTextLabel.backgroundColor = [self.tweet moodColor];
    self.tweetTextLabel.textColor = [UIColor whiteColor];
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)displayMood
{
    if (self.tweet.mood != TWMoodUndefined)
    {
        POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
        springAnimation.springBounciness = 20;
        springAnimation.springSpeed = 20;
        springAnimation.toValue = @(MAX(30.f, self.tweet.moodScore * 350.f));
        [self.graphViewWidthConstraint pop_addAnimation:springAnimation forKey:@"layoutAnimation"];
        self.smileyView.moodScore = self.tweet.moodScore;
        self.smileyView.hidden = NO;
    }
    else
    {
        self.smileyView.hidden = YES;
    }
}

- (void)rotateView
{
    BOOL shallShowLabel = CATransform3DIsIdentity(self.contentView.layer.transform);

    [self refreshViewToShowLabel:shallShowLabel animated:YES];
}

/********************************************************************************/
#pragma mark - Private Methods

- (void)refreshViewToShowLabel:(BOOL)shallShowLabel animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? .5f : .0f) animations:^
    {
        self.contentView.layer.transform = shallShowLabel ? CATransform3DMakeRotation(M_PI, 1, 0, 0) : CATransform3DIdentity;
        self.graphView.alpha = shallShowLabel ? 0.f : 1.f;
        self.smileyView.alpha = shallShowLabel ? 0.f : 1.f;
        self.tweetTextLabel.alpha = shallShowLabel ? 1.f : 0.f;
    }];
}

@end
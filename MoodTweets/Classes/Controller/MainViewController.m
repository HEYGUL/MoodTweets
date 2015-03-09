//
//  MainViewController.m
//  I am a Buffer
//
//  Created by Guillaume Lagorce on 17/01/15.
//  Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "MainViewController.h"
#import "TwitterManager.h"
#import "Tweet.h"
#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import "NaturalLanguageService.h"
#import "NSMutableArray+Shuffle.h"
#import "MoodTableViewCell.h"
#import <STTwitter/STTwitterAPI.h>
#import <Accounts/Accounts.h>
#import <Bolts/Bolts.h>

NSString *const kMoodCellIdentifier = @"moodCellIdentifier";

@interface MainViewController () <UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) UIImage *profileImage;
@property(nonatomic, strong) NSArray *tweets;
@property(nonatomic, strong) NSArray *iOSAccounts;
@property(nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property(nonatomic, weak) IBOutlet UILabel *connectedAccountLabel;

@property(nonatomic, weak) IBOutlet UIVisualEffectView *effectView;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIView *menuView;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *menuViewHeightConstraints;
@property(nonatomic, weak) IBOutlet UIImageView *expandImageView;
@property(nonatomic, weak) IBOutlet UIButton *profileButton;

@property(nonatomic, weak) IBOutlet UIButton *tutoButton;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _tweets = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self configureView];
    
    if (self.tutoButton.hidden)
    {
        [self loadData];
    }
}

/********************************************************************************/
#pragma mark - Custom Getters / Setters

- (void)setUsername:(NSString *)username
{
    _username = username;
    self.usernameTextField.text = _username;
}

/********************************************************************************/
#pragma mark - IBActions

- (IBAction)tutoButtonDidTap:(id)sender
{
    self.tutoButton.hidden = YES;
    [self loadData];
}

/********************************************************************************/
#pragma mark - Private Methods

- (void)configureView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor cloudsColor];
    self.tableView.backgroundColor = [UIColor cloudsColor];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.menuView.layer.cornerRadius = 3.f;
    self.menuView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.menuView.layer.borderWidth = 1.f;
    self.menuView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.menuView.layer.shadowRadius = 3.f;
    self.menuView.layer.shadowOffset = CGSizeMake(2.f, 2.f);
    self.menuView.layer.masksToBounds = YES;
    self.menuView.layer.shadowOpacity = .8f;
    self.effectView.transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(self.view.frame));
    
    self.profileButton.layer.cornerRadius = CGRectGetWidth(self.profileButton.frame) / 2.f;
    self.profileButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.profileButton.layer.borderWidth = 1.f;
    self.profileButton.clipsToBounds = YES;
}

- (void)refreshView
{
    [self.tableView reloadData];
}

- (void)refreshViewForTweet:(Tweet *)tweet
{
    NSInteger row = [self.tweets indexOfObject:tweet];;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (void)loadData
{
    BFTask *twitterTask = [[TwitterManager sharedManager] accessTwitterAccounts];
    [[[[[[twitterTask continueWithExecutor:[BFExecutor mainThreadExecutor]
                         withSuccessBlock:^id(BFTask *task)
         {
             BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
             self.iOSAccounts = task.result;
             
             if ([_iOSAccounts count] == 0)
             {
                 [source setResult:nil];
                 [[[UIAlertView alloc] initWithTitle:@"Error"
                                             message:@"No twitter account found. Please check your phone's settings."
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
             else
             {
                 ACAccount *account = [self.iOSAccounts firstObject];
                 return [self loginToTwitterWithAccount:account];
             }
             return source.task;
         }]
        continueWithSuccessBlock:^id(BFTask *task)
        {
            self.connectedAccountLabel.text = [NSString stringWithFormat:@"Connected as @%@",task.result];
            if(self.username.length == 0)
            {
                self.username = task.result;
            }
            [self refreshView];
            return [[TwitterManager sharedManager] loadProfileImageForUser:self.username];
        }]
       continueWithBlock:^id(BFTask *task) {
           self.profileImage = task.result;
           [self.profileButton setBackgroundImage:self.profileImage forState:UIControlStateNormal];
           return [self loadTimeline];
       }]
       continueWithExecutor:[BFExecutor mainThreadExecutor]
       withBlock:^id(BFTask *task)
       {
           self.tweets = task.result;
           [self refreshView];
           if (task.error)
           {
               [self manageError:task.error];
           }
           return task;
       }]
      continueWithSuccessBlock:^id(BFTask *task)
      {
          NSMutableArray *tasks = [NSMutableArray array];
          NSMutableArray *shuffledTweets = [self.tweets mutableCopy];
          [shuffledTweets shuffle];
          for (Tweet *tweet in shuffledTweets)
          {
              [tasks addObject:[self moodForTweet:tweet]];
          }
          return [BFTask taskForCompletionOfAllTasks:tasks];
      }]
     continueWithExecutor:[BFExecutor mainThreadExecutor]
     withBlock:^id(BFTask *task)
     {
         if (task.error)
         {
             [self manageError:task.error];
         }
         return task;
     }];
}

- (BFTask *)loginToTwitterWithAccount:(ACAccount *)account
{
    return [[TwitterManager sharedManager] loginWithiOSAccount:account];
}

- (void)manageError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Please check your internet connection and try again later."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (BFTask *)loadTimeline
{
    return [[TwitterManager sharedManager] loadTimelineWithUser:self.username];
}

- (BFTask *)moodForTweet:(Tweet *)tweet
{
    return [[NaturalLanguageService moodForTweet:tweet]
            continueWithExecutor:[BFExecutor mainThreadExecutor]
                       withBlock:^id(BFTask *task)
                       {
                           if (!task.error)
                           {
                               [self refreshViewForTweet:tweet];
                           }
                           return task;
                       }];
}

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMoodCellIdentifier];
    
    Tweet *tweet = self.tweets[(NSUInteger) indexPath.row];
    cell.tweet = tweet;
    [cell displayMood];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

/********************************************************************************/
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MoodTableViewCell *cell = (MoodTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.tweet.mood != TWMoodUndefined)
    {
        [cell rotateView];
    }
}

/********************************************************************************/
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _username = textField.text;
    [self loadData];
    [textField resignFirstResponder];
    [self showMenu:nil];
    return YES;
}

- (BOOL)menuIsExpanded
{
    return !CGAffineTransformIsIdentity(self.expandImageView.transform);
}

/********************************************************************************/
#pragma mark - Menu View

- (IBAction)showMenu:(id)sender
{
    BOOL willShow = !CGAffineTransformIsIdentity(self.effectView.transform);
    
    if (willShow)
    {
        [self.usernameTextField becomeFirstResponder];
    }
    else
    {
        [self.usernameTextField resignFirstResponder];
    }
    
    [UIView animateWithDuration:.3f
                     animations:^{
                         self.effectView.transform = willShow ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(self.view.frame));
                     }];
}

@end
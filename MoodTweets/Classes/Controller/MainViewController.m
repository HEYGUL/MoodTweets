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

@interface MainViewController () <UIViewControllerTransitioningDelegate, UIActionSheetDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSArray *tweets;
@property(nonatomic, strong) NSArray *iOSAccounts;

@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self configureView];
    [self loadData];
}

/********************************************************************************/
#pragma mark - Private Methods

- (void)configureView
{
    self.tableView.backgroundColor = [UIColor cloudsColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
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
    [[[[[twitterTask continueWithExecutor:[BFExecutor mainThreadExecutor]
                         withSuccessBlock:^id(BFTask *task)
                         {
                             self.iOSAccounts = task.result;

                             if ([_iOSAccounts count] == 1)
                             {
                                 ACAccount *account = [self.iOSAccounts lastObject];
                                 return [self loginToTwitterWithAccount:account];
                             }
                             else
                             {
                                 UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                                          delegate:self
                                                                                 cancelButtonTitle:@"Cancel"
                                                                            destructiveButtonTitle:nil otherButtonTitles:nil];
                                 for (ACAccount *account in self.iOSAccounts)
                                 {
                                     [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                                 }
                                 [actionSheet showInView:self.view.window];
                             }
                             return task;
                         }]
            continueWithSuccessBlock:^id(BFTask *task)
            {
                self.username = task.result;
                [self refreshView];
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
                                message:[error description]
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
    return [[[NaturalLanguageService new] moodForTweet:tweet]
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
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        NSUInteger accountIndex = (NSUInteger) (buttonIndex - 1);
        ACAccount *account = _iOSAccounts[accountIndex];

        [self loginToTwitterWithAccount:account];
    }
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

@end
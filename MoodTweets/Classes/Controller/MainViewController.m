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
//#import "HeaderView.h"

NSString *const kMoodCellIdentifier = @"moodCellIdentifier";

@interface MainViewController () <UIViewControllerTransitioningDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSArray *tweets;
@property(nonatomic, strong) NSArray *iOSAccounts;

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
             BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
             self.iOSAccounts = task.result;
             
             if([_iOSAccounts count] == 0)
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
                                message:@"Please check your internet connection and retry later."
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil] firstObject];
//    headerView.text = [NSString stringWithFormat:@"Connected as @%@", self.username];
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.f;
}

/********************************************************************************/
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MoodTableViewCell *cell = (MoodTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.tweet.mood != TWMoodUndefined)
    {
        [cell rotateView];
    }
}

@end
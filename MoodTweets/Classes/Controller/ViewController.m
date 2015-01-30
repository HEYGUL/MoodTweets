//
//  ViewController.m
//  I am a Buffer
//
//  Created by Guillaume Lagorce on 17/01/15.
//  Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "ViewController.h"
#import "TwitterManager.h"
#import "Tweet.h"
#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UITableViewCell+FlatUI.h"
#import <STTwitter/STTwitterAPI.h>
#import <Accounts/Accounts.h>
#import <Bolts/Bolts.h>


@interface ViewController () <UIViewControllerTransitioningDelegate, UIActionSheetDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSArray *tweets;

@end

@implementation ViewController

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
    self.view.backgroundColor = [UIColor cloudsColor];
    self.tableView.separatorColor = [UIColor cloudsColor];
    self.tableView.backgroundColor = [UIColor cloudsColor];
    self.tableView.backgroundView = nil;
}

- (void)refreshView
{
    [self.tableView reloadData];
}

- (void)loadData
{
    BFTask *twitterTask = [[TwitterManager sharedManager] accessTwitterAccounts];
    [[[twitterTask continueWithExecutor:[BFExecutor mainThreadExecutor]
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    UIRectCorner corners = [self cornersForTableView:tableView indexPath:indexPath];
    [cell configureFlatCellWithColor:[UIColor greenSeaColor]
                       selectedColor:[UIColor cloudsColor]
                     roundingCorners:corners];
    cell.separatorHeight = 0.f;

    Tweet *tweet = self.tweets[(NSUInteger) indexPath.row];

    cell.textLabel.text = tweet.text;
    cell.textLabel.font = [UIFont boldFlatFontOfSize:16];

    return cell;
}

- (UIRectCorner)cornersForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UIRectCorner corners = 0;
    if (tableView.style == UITableViewStyleGrouped)
    {
        if ([tableView numberOfRowsInSection:indexPath.section] == 1)
        {
            corners = UIRectCornerAllCorners;
        }
        else if (indexPath.row == 0)
        {
            corners = UIRectCornerTopLeft | UIRectCornerTopRight;
        }
        else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        {
            corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
        }
    }
    return corners;
}

@end
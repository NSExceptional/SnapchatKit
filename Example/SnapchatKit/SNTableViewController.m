//
//  SNTableViewController.m
//  SnapchatKit-iOS-Demo
//
//  Created by Tanner on 7/11/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "SNTableViewController.h"
#import "SnapchatKit.h"

#define kReuse @"reuse"

@implementation SNTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuse];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    <#XXTableViewCell#> *cell = <#self.dataSource[indexPath.row]#>;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kReuse];
    SKConversation *convo = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ — %luu pending", convo.participants.firstObject, convo.pendingRecievedSnaps.count];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end

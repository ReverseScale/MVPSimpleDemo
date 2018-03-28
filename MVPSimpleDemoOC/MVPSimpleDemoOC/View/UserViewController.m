//
//  UserViewController.m
//  MVPSimpleDemoOC
//
//  Created by WhatsXie on 2018/3/28.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "UserViewController.h"
#import "UserProtocol.h"
#import "UserPresenter.h"

@interface UserViewController ()<UserProtocol,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,strong) NSArray *friendlyUIData;
@property (nonatomic,strong) UserPresenter *presenter;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    self.presenter = [UserPresenter new];
    [self.presenter attachView:self];
    [self.presenter fetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendlyUIData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [self.friendlyUIData[indexPath.row] valueForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma UserViewProtocol
- (void)showIndicator {
    self.activityIndicator.hidden = NO;
}
- (void)hideIndicator {
    self.activityIndicator.hidden = YES;
}
- (void)userDataSource:(NSArray*)data {
    self.emptyView.hidden = YES;
    self.tableview.hidden = NO;
    
    self.friendlyUIData = data;
    [self.tableview reloadData];
}
- (void)showEmptyView {
    self.emptyView.hidden = NO;
    self.tableview.hidden = YES;
}
@end

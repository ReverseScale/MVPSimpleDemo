//
//  UserPresenter.m
//  MVPSimpleDemoOC
//
//  Created by WhatsXie on 2018/3/28.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "UserPresenter.h"
#import "UserService.h"

@interface UserPresenter()

@property (nonatomic,strong) UserService *userService;

@property (nonatomic,weak) id<UserProtocol> attachView;

@end

@implementation UserPresenter
- (void)attachView:(id <UserProtocol>)view {
    self.attachView = view;
    self.userService  = [UserService new];
}

// 这个是对外的入口，通过这个入口，实现多个对内部的操作，外部只要调用这个接口就可以了
- (void)fetchData {
    [self getUserDatas];
}

// 对内的业务逻辑方法，
- (void)getUserDatas {
    [self.attachView showIndicator];
    [_userService getUserInfosSuccess:^(NSDictionary *dic) {
        [self.attachView hideIndicator];
        NSArray *userArr =[dic valueForKey:@"data"];
        
        if ([self processOriginDataToUIFriendlyData:userArr].count == 0) {
            [self.attachView showEmptyView];
        }
        [self.attachView userDataSource:[self processOriginDataToUIFriendlyData:userArr]];
    } andFail:^(NSDictionary *dic) {
        
    }];
}

// 如果数据比较复杂，或者UI渲染的数据只是其中很少一部分，将原数据处理，输出成UI渲染的数据。（题外话：这里其实还可以使用协议，提供不同的数据格式输出。）
- (NSArray *)processOriginDataToUIFriendlyData:(NSArray *) originData {
    NSMutableArray *friendlyUIData = [NSMutableArray new];
    for (NSDictionary *dic in originData) {
        if ([[dic valueForKey:@"gender"] isEqualToString:@"male"]) {
            [friendlyUIData addObject:dic];
        }
    }
    return friendlyUIData;
}

@end

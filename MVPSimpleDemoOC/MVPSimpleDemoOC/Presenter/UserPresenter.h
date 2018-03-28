//
//  UserPresenter.h
//  MVPSimpleDemoOC
//
//  Created by WhatsXie on 2018/3/28.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProtocol.h"

@interface UserPresenter : NSObject
/**
 *  将一个实现了 UserViewProtocol 协议的对象绑定到 presenter上来
 *
 *  @param view 实现了UserViewProtocol的对象，一般来说，应该就是控制器，在MVP中，V 和 VC 共同组成UI 层。
 */
- (void)attachView:(id <UserProtocol>)view;

- (void)fetchData;
@end

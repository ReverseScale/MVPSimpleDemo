//
//  UserService.h
//  MVPSimpleDemoOC
//
//  Created by WhatsXie on 2018/3/28.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessHandler)(NSDictionary *dic);
typedef void(^FailHandler)(NSDictionary *dic);
/**
 *  Service 用来做数据获取工作等，发起网络请求，并且返回数据给Presenter，这个算是Model，但我准备用字典做业务交付
 */
@interface UserService: NSObject
- (void)getUserInfosSuccess:(SuccessHandler )success andFail:(FailHandler) fail;
@end

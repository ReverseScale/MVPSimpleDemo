//
//  UserService.m
//  MVPSimpleDemoOC
//
//  Created by WhatsXie on 2018/3/28.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import "UserService.h"

@implementation UserService
- (void)getUserInfosSuccess:(SuccessHandler )success andFail:(FailHandler) fail {
    NSArray *result = @[@{@"name":@"Iyad",
                          @"age":@25,
                          @"addr":@"GuangZhou",
                          @"gender":@"male",
                          },
                        @{@"name":@"Mila",
                          @"age":@22,
                          @"addr":@"Hangzhou",
                          @"gender":@"male",
                          },
                        @{@"name":@"Mark",
                          @"age":@25,
                          @"addr":@"Didu",
                          @"gender":@"female",
                          }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        success(@{@"data":result});
    });
}
@end

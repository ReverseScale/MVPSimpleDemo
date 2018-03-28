//
//  UserProtocol.h
//  MVPSimpleDemoOC
//
//  Created by WhatsXie on 2018/3/28.
//  Copyright © 2018年 WhatsXie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserProtocol <NSObject>

- (void)userDataSource:(NSArray*)data;
- (void)showIndicator;
- (void)hideIndicator;
- (void)showEmptyView;

@end

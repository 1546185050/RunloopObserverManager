//
//  RunloopObserverManager.h
//  RunloopObserver
//
//  Created by dhp on 2018/5/8.
//  Copyright © 2018年 dhp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunloopObserverManager : NSObject

+ (instancetype)sharedManager;

- (void)startObserver;

- (void)endObserver;

@end

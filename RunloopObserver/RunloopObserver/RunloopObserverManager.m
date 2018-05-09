//
//  RunloopObserverManager.m
//  RunloopObserver
//
//  Created by dhp on 2018/5/8.
//  Copyright © 2018年 dhp. All rights reserved.
//

#import "RunloopObserverManager.h"
#import <objc/runtime.h>

/*
 * 使用CFRunLoopObserverRef监控NSRunLoop的状态，以实时获得这些状态值（kCFRunLoopBeforeSources、kCFRunLoopBeforeWaiting、kCFRunLoopAfterWaiting等）的变化。开启一个子线程，实时计算主线程NSRunLoop两个状态区域之间的耗时是否到达某个阀值，从而判断是否卡顿。
 */

@interface RunloopObserverManager ()
{
    int timeoutCount;
    CFRunLoopObserverRef observer;//观察者，每个 Observer 都包含了一个回调（函数指针），当 RunLoop 的状态发生变化时，观察者就能通过回调接受到这个变化
    dispatch_semaphore_t semaphore;//信号量
    CFRunLoopActivity activity;
}

@end

@implementation RunloopObserverManager

#pragma mark - public method
+ (instancetype)sharedManager {
    static RunloopObserverManager *manager = nil;
    
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        manager = [[RunloopObserverManager alloc] init];
    });
    
    return manager;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    RunloopObserverManager *observerManager = (__bridge RunloopObserverManager*)info;
    observerManager->activity = activity;
    
    dispatch_semaphore_t semaphore = observerManager->semaphore;
    //发送信号
    dispatch_semaphore_signal(semaphore);
}

- (void)startObserver {
    [self registerObserver];
}


- (void)endObserver {
    if (!observer) {
        return;
    }
    
    //移除观察者
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    observer = NULL;
}

#pragma mark - private method
- (void)registerObserver {
    if (observer) {
        return;
    }
    
    semaphore = dispatch_semaphore_create(0);
    
    //注册RunLoop状态观察
    //设置Run loop observer的运行环境
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    
    /**
     创建Run loop observer对象
     
     @param kCFAllocatorDefault 分配observer对象的内存
     @param kCFRunLoopAllActivities 设置observer所要关注的事件
     @param YES 标识该observer是在第一次进入run loop时执行还是每次进入run loop处理时均执行
     @param 0 设置该observer的优先级
     @param runLoopObserverCallBack 设置该observer的回调函数
     @param context 设置该observer的运行环境
     @return Run loop observer对象
     */
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    //主线程卡顿监测：通过子线程监测时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (YES) {
            //假设连续5次超时50ms认为卡顿
            long t = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC));
            
            if (t != 0) {
                if (activity == kCFRunLoopBeforeSources || activity == kCFRunLoopAfterWaiting)
                {
                    if (++timeoutCount < 5)
                        continue;
                    
                   //可自行做卡顿处理，如打印堆栈信息等
                    NSLog(@"--自行做卡顿处理，如打印堆栈信息等--");
                }
                
                timeoutCount = 0;
            }
        }
    });
}

@end

//
//  ViewController.m
//  RunloopObserver
//
//  Created by dhp on 2018/5/8.
//  Copyright © 2018年 dhp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.table];
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _table.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = @"测试";
    if (indexPath.row%5 == 0) {
        cell.textLabel.text = @"卡顿";
        sleep(1.0);
    }
    
    return cell;
}

#pragma mark - getter && setter
- (UITableView *)table {
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.rowHeight = 50;
    }
    return _table;
}

@end

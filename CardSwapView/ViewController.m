//
//  ViewController.m
//  CardSwapView
//
//  Created by slash on 2019/8/22.
//  Copyright © 2019 slash. All rights reserved.
//

#import "ViewController.h"
#import "CardDrapView.h"
#import "CardDrapItem.h"
#import <Masonry.h>

@interface ViewController ()<CardDrapViewDelegate, CardDrapViewDataSource>
// <#type#>
@property (nonatomic, strong) CardDrapView *drapView;
// <#type#>
@property (nonatomic, strong) UIButton *likeBtn;
// <#type#>
@property (nonatomic, strong) UIButton *notLikeBtn;
// <#type#>
@property (nonatomic, strong) UIButton *callbackBtn;
// <#type#>
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.drapView];
    [self.view addSubview:self.notLikeBtn];
    [self.view addSubview:self.callbackBtn];
    [self.view addSubview:self.likeBtn];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dataSource addObjectsFromArray:[self datas]];
        [self.drapView reloadData];
    });
}

- (NSArray *)datas {
    return @[@"1",@"2", @"3", @"4", @"5", @"6", @"7"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.drapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 0, 200, 0));
    }];
    
    [self.notLikeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.drapView.mas_bottom).offset(10);
        make.height.mas_equalTo(44);
    }];
    
    [self.callbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.notLikeBtn);
        make.left.equalTo(self.notLikeBtn.mas_right).offset(10);
        make.height.width.equalTo(self.notLikeBtn);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.notLikeBtn);
        make.left.equalTo(self.callbackBtn.mas_right).offset(10);
        make.height.width.equalTo(self.notLikeBtn);
        make.right.equalTo(self.view).offset(-10);
    }];
}
- (NSInteger)numberOfCardDrapView:(CardDrapView *)drapView {
    return self.dataSource.count;
}

- (CardDrapItem *)cardDrapView:(CardDrapView *)drapView itemForIndex:(NSInteger)index {
    CardDrapItem *item = [drapView dequeueReusableItemWithIdentifier:@"item"];
    item.img = self.dataSource[index];
    return item;
}

- (NSArray *)dataSourceWithCardDrapView:(CardDrapView *)drapView {
    return self.dataSource;
}

- (void)cardDrapView:(CardDrapView *)drapView drapWillBeginInIndex:(NSInteger)index {
    
}

- (void)cardDrapView:(CardDrapView *)drapView drapEndInIndex:(NSInteger)index {
    
}

- (void)cardDrapView:(CardDrapView *)drapView didSelctedInIndex:(NSInteger)index {
    
}


- (void)touchLike {
    [self.drapView autoDrapRightItem];
}

- (void)touchNotLike {
    [self.drapView autoDrapLeftItem];
}

- (void)touchCallback {
    [self.drapView callbacRemovekItem];
}

- (CardDrapView *)drapView {
    if (_drapView == nil) {
        _drapView = [[CardDrapView alloc] init];
        _drapView.delegate = self;
        _drapView.dataSource = self;
        [_drapView registerClass:[CardDrapItem class] forItemReuseIdentifier:@"item"];
    }
    return _drapView;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIButton *)likeBtn {
    if (_likeBtn == nil) {
        _likeBtn = [[UIButton alloc] init];
        [_likeBtn setTitle:@"like" forState:UIControlStateNormal];
        [_likeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_likeBtn addTarget:self action:@selector(touchLike) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)notLikeBtn {
    if (_notLikeBtn == nil) {
        _notLikeBtn = [[UIButton alloc] init];
        [_notLikeBtn setTitle:@"notLike" forState:UIControlStateNormal];
        [_notLikeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_notLikeBtn addTarget:self action:@selector(touchNotLike) forControlEvents:UIControlEventTouchUpInside];
    }
    return _notLikeBtn;
}

- (UIButton *)callbackBtn {
    if (_callbackBtn == nil) {
        _callbackBtn = [[UIButton alloc] init];
        [_callbackBtn setTitle:@"callback" forState:UIControlStateNormal];
        [_callbackBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_callbackBtn addTarget:self action:@selector(touchCallback) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callbackBtn;
}

@end

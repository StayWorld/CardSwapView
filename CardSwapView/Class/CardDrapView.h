//
//  CardDrapView.h
//
//  Created by slash on 2019/8/1.
//  Copyright © 2019 slash. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DrapDirection) {
    DrapDirectionLeft,
    DrapDirectionRight,
    DrapDirectionNone
};

@class CardDrapItem, CardDrapView;

@protocol CardDrapViewDelegate <NSObject>
// 点击滑块
- (void)cardDrapView:(CardDrapView *)drapView didSelctedInIndex:(NSInteger)index;
// 结束滑动
- (void)cardDrapView:(CardDrapView *)drapView drapEndInIndex:(NSInteger)index;
// 将要结束滑动
- (void)cardDrapView:(CardDrapView *)drapView drapWillBeginInIndex:(NSInteger)index;
// 无数据提示
- (void)alterNoDataWithcardDrapView:(CardDrapView *)drapView;

@end

@protocol CardDrapViewDataSource <NSObject>
// 个数
- (NSInteger)numberOfCardDrapView:(CardDrapView *)drapView;
// item 数据源
- (CardDrapItem *)cardDrapView:(CardDrapView *)drapView itemForIndex:(NSInteger)index;
// 数据源
- (NSArray *)dataSourceWithCardDrapView:(CardDrapView *)drapView;

@end

@interface CardDrapView : UIView
// 滑动方向
@property (nonatomic, assign, readonly) DrapDirection direction;
// 网络加载loading
@property (nonatomic, assign, readonly) BOOL isLoading;
// 滑块是否正在移动
@property (nonatomic, assign, readonly) BOOL isMove;
// 当前index
@property (nonatomic, assign, readonly) NSInteger currentIndex;

// delegate
@property (nonatomic, weak) id<CardDrapViewDelegate>delegate;
// datasource
@property (nonatomic, weak) id<CardDrapViewDataSource>dataSource;

- (CardDrapItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier;

- (void)registerClass:(Class)class forItemReuseIdentifier:(nonnull NSString *)identifier;
// 自动左滑
- (void)autoDrapLeftItem;
// 自动右划
- (void)autoDrapRightItem;
// 回滚
- (void)callbacRemovekItem;
// 刷新数据
- (void)reloadData;
// 重新加载item，包括关联的属性
- (void)updateUI;
// 手动结束loading
- (void)endLoading;

@end

@interface UIView (Drap)
// 记录item标识（indentifier）
@property (nonatomic, copy) NSString *reuseIdentifier;

@end

NS_ASSUME_NONNULL_END

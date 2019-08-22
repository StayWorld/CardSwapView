//
//  CardDrapView.m
//
//  Created by slash on 2019/8/1.
//  Copyright © 2019 slash. All rights reserved.
//

#import "CardDrapView.h"
#import "CardDrapItem.h"
#import <objc/runtime.h>

#define UI_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define UI_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CardDrapView ()
// <#type属性#>
@property (nonatomic, strong) NSMutableDictionary *itemCache;
// <#type属性#>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *reuseViews;
// <#type属性#>
@property (nonatomic, strong) NSMutableSet<UIView *> *visibleViews;
// <#type属性#>
@property (nonatomic, strong) NSMutableArray<UIView *> *items;
// <#type#>
@property (nonatomic, strong) NSMutableArray *itemDataSource;


// <#type属性#>
@property (nonatomic, assign) NSInteger nowIndex;
// <#type属性#>
@property (nonatomic, assign) DrapDirection direction;
// <#type#>
@property (nonatomic, assign) NSInteger currentIndex;

// <#type属性#>
@property (nonatomic, strong) UIImageView *placeHolderImgView;
// <#type#>
@property (nonatomic, strong) UIView *callbackView;
// <#type#>
@property (nonatomic, strong) UIView *drapView;


@property (nonatomic, assign) BOOL isLoading;
// <#type#>
@property (nonatomic, assign) BOOL isMove;
// <#type#>
@property (nonatomic, assign) NSInteger everyCount;


@end

@implementation CardDrapView {
    CGPoint _originalCenter;
    BOOL _firstLoad;
    CGFloat _angle;
    UIView *_finalView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _firstLoad = YES;
        _isLoading = NO;
        _everyCount = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(!_firstLoad) return;
    self.placeHolderImgView.frame = CGRectMake(20, 20, (UI_SCREEN_WIDTH - 40), self.frame.size.height - 20);
    [self addSubview:self.placeHolderImgView];
//    [self defaultInitUI];
    _firstLoad = NO;
}


- (void)defaultInitUI {
    NSInteger count = 0;
    NSInteger spaceTime = 0;
    if ([self.dataSource  respondsToSelector:@selector(numberOfCardDrapView:)]) {
        count = [self.dataSource numberOfCardDrapView:self];
    }
    if (!count) {
        [self _noDataAlter];
        return;
    }
    
    if (count >= self.everyCount + 5) {// than five
        spaceTime = 5;
    } else if ((count - self.everyCount) > 0 && (count - self.everyCount) < 5) { // less five and than zero
        spaceTime = count - self.everyCount;
    } else {
        [self _noDataAlter];
        return;
    }
        
    UIView *lastView = nil;
    for (NSInteger i = self.everyCount; i < self.everyCount+spaceTime; i++) {
        CardDrapItem *item = [self createDrapViewWithIndex:i];
        item.frame = CGRectMake(20, 20, (UI_SCREEN_WIDTH - 40), self.frame.size.height - 20);
        item.notLikeImageView.alpha = 0.0;
        item.likeImageView.alpha = 0.0;
        _originalCenter = item.center;
        [self.visibleViews addObject:item];
        [self.items addObject:item];
        if (lastView) {
            [self insertSubview:item belowSubview:lastView];
        } else {
            if (_finalView) {
                [self insertSubview:item belowSubview:_finalView];
            } else {
                [self addSubview:item];
            }
        }
        lastView = item;
        if (i == count - 1) {
            _finalView =  lastView;
        }
    }
    
    self.isLoading = YES;
    self.everyCount += spaceTime;
}

- (void)endLoading {
    self.isLoading = YES;
}

- (void)updateUI {
    for (UIView *view in self.visibleViews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            continue;
        }
        [view removeFromSuperview];
    }

    [self.visibleViews removeAllObjects];
    [self.items removeAllObjects];
    [self.itemDataSource removeAllObjects];
    [self.reuseViews removeAllObjects];
    self.nowIndex = 0;
    self.direction = DrapDirectionNone;
    self.callbackView = nil;
    self.isLoading = NO;
    self.everyCount = 0;
}
- (void)reloadData {
    [self.itemDataSource removeAllObjects];
    [self.itemDataSource addObjectsFromArray:[self.dataSource dataSourceWithCardDrapView:self]];
    self.isLoading = NO;
    
    [self defaultInitUI];
}

- (void)drapWithPan:(UIPanGestureRecognizer *)pan {
    CardDrapItem *item = (CardDrapItem *)pan.view;
//    [item layoutIfNeeded];
    self.isMove = YES;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            for (CardDrapItem *otherItem in self.visibleViews) {
                if (![item isEqual:otherItem]) {
                    otherItem.userInteractionEnabled = NO;
                }
            }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint movePoint = [pan translationInView:self];
            item.center = CGPointMake(item.center.x + movePoint.x, item.center.y + movePoint.y);
            self->_angle = (item.center.x - item.frame.size.width * 0.5) / item.frame.size.width * 0.5;
            item.transform = CGAffineTransformMakeRotation(self->_angle);
            if (self->_originalCenter.x > item.center.x) {
                self.direction = DrapDirectionLeft;
                item.notLikeImageView.alpha = [self _presentDirectionMarkImgeWithPoint:item.center];
            } else {
                self.direction = DrapDirectionRight;
                item.likeImageView.alpha = [self _presentDirectionMarkImgeWithPoint:item.center];
            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.isMove = NO;
            if (ABS(self->_angle * 180) >= 30) {
                if (self->_originalCenter.x > item.center.x) {
                    self.direction = DrapDirectionLeft;
                } else {
                    self.direction = DrapDirectionRight;
                }
                if ([self.delegate respondsToSelector:@selector(cardDrapView:drapWillBeginInIndex:)]) {
                    [self.delegate cardDrapView:self drapWillBeginInIndex:self.nowIndex];
                }

                [UIView animateWithDuration:0.3 animations:^{
                    if (self->_originalCenter.x > item.center.x) {
                        item.center = CGPointMake(item.center.x - item.frame.size.width, item.center.y);
                        item.notLikeImageView.alpha = [self _presentDirectionMarkImgeWithPoint:item.center];
                        item.transform = CGAffineTransformMakeRotation(MIN(-self->_angle, -30 * M_PI/180.0));
                    } else {
                        item.center = CGPointMake(item.center.x + item.frame.size.width, item.center.y);
                        item.likeImageView.alpha = [self _presentDirectionMarkImgeWithPoint:item.center];
                        item.transform = CGAffineTransformMakeRotation(MAX(self->_angle, 30 * M_PI/180.0));
                    }
                } completion:^(BOOL finished) {
                    [self _completionHandlerWithView:item];
                    if (self.callbackView == nil) { // no callbackView
                        if ([self.delegate respondsToSelector:@selector(cardDrapView:drapEndInIndex:)]) {
                            [self.delegate cardDrapView:self drapEndInIndex:self.nowIndex];
                        }
                    }
                    self.callbackView = nil;
                    self.nowIndex++;
                }];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.direction = DrapDirectionNone;
                    item.center = self->_originalCenter;
                    item.transform = CGAffineTransformMakeRotation(0);
                    item.notLikeImageView.alpha = 0;
                    item.likeImageView.alpha = 0;
                }];
            }
        }
            break;
        default:
            NSLog(@"error");
            break;
    }
    [pan setTranslation:CGPointZero inView:self];
}

- (void)enqueueReusableView:(UIView *)view {
    if (!view.reuseIdentifier) {
        return;
    }
    NSString *identifier = view.reuseIdentifier;
    NSMutableSet *reuseSet = self.reuseViews[identifier];
    if (!reuseSet) {
        reuseSet = [NSMutableSet set];
        [self.reuseViews setValue:reuseSet forKey:identifier];
    }
    [reuseSet addObject:view];
}

- (void)touchWithTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(cardDrapView:didSelctedInIndex:)]) {
        [self.delegate cardDrapView:self didSelctedInIndex:self.nowIndex];
    }
}

- (UIView *)createCallbackView {
    NSMutableSet *reuseSet = self.reuseViews[@"callback"];
    UIView *view = [reuseSet anyObject];
    if (view) {
        return (CardDrapItem *)view;
    }
    CardDrapItem * item= [[CardDrapItem alloc] initWithReuseIdentifier:@"callback"];
    item.reuseIdentifier = @"callback";
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drapWithPan:)];
    [item addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchWithTap:)];
    [item addGestureRecognizer:tap];
    item.userInteractionEnabled = YES;
    item.frame = CGRectMake(0, 0, (UI_SCREEN_WIDTH - 40), self.frame.size.height - 20);
    [self.visibleViews addObject:item];
    return item;
}

- (CardDrapItem *)createDrapViewWithIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(cardDrapView:itemForIndex:)]) {
        CardDrapItem *item = [self.dataSource cardDrapView:self itemForIndex:index];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drapWithPan:)];
        [item addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchWithTap:)];
        [item addGestureRecognizer:tap];
        item.userInteractionEnabled = YES;
        return item;
    }
    return nil;
}


- (CardDrapItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return nil;
    }
    NSMutableSet *reuseSet = self.reuseViews[identifier];
    UIView *view = [reuseSet anyObject];
    if (view) {
        [reuseSet removeObject:view];
        view.center = _originalCenter;
        view.transform = CGAffineTransformMakeRotation(0);
        return (CardDrapItem *)view;
    } else {
        Class class = [self.itemCache objectForKey:identifier];
        CardDrapItem * item= [[class alloc] initWithReuseIdentifier:identifier];
        item.reuseIdentifier = identifier;
        
        return item;
    }
}

- (void)registerClass:(Class)class forItemReuseIdentifier:(NSString *)identifier {
    [self.itemCache setValue:class forKey:identifier];
}

- (void)autoDrapLeftItem {
    if (self.isMove) {
        return;
    }
    if (self.items.count <= self.nowIndex) {
        return;
    }
    self.isMove = YES;
    CardDrapItem *item = nil;
    if (self.callbackView) {
        item = (CardDrapItem *)self.callbackView;
        item.transform = CGAffineTransformMakeRotation(0);
    } else {
        item = (CardDrapItem *)[self.items objectAtIndex:self.nowIndex];
    }
    self.direction = DrapDirectionLeft;
    if ([self.delegate respondsToSelector:@selector(cardDrapView:drapWillBeginInIndex:)]) {
        [self.delegate cardDrapView:self drapWillBeginInIndex:self.nowIndex];
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint point = item.center;
        point.x -= self.frame.size.width * 0.5 + item.frame.size.width * 0.5;
        item.center = point;
        item.transform = CGAffineTransformMakeRotation( -30 * M_PI/180.0);
        item.notLikeImageView.alpha = [self _presentDirectionMarkImgeWithPoint:item.center];

    } completion:^(BOOL finished) {
        self.isMove = NO;
        [self _completionHandlerWithView:item];
        
        if (self.callbackView == nil) {
            if ([self.delegate respondsToSelector:@selector(cardDrapView:drapEndInIndex:)]) {
                [self.delegate cardDrapView:self drapEndInIndex:self.nowIndex];
            }
        }
        self.callbackView = nil;

        self.nowIndex++;

    }];
}

- (void)autoDrapRightItem {
    if (self.isMove) {
        return;
    }
    if (self.items.count <= self.nowIndex) {
        return;
    }
    self.isMove = YES;
    CardDrapItem *item = nil;
    if (self.callbackView) {
        item = (CardDrapItem *)self.callbackView;
        item.transform = CGAffineTransformMakeRotation(0);
    } else {
        item = (CardDrapItem *)[self.items objectAtIndex:self.nowIndex];
    }
    self.direction = DrapDirectionRight;
    if ([self.delegate respondsToSelector:@selector(cardDrapView:drapWillBeginInIndex:)]) {
        [self.delegate cardDrapView:self drapWillBeginInIndex:self.nowIndex];
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint point = item.center;
        point.x += self.frame.size.width * 0.5 + item.frame.size.width * 0.5;
        item.center = point;
        item.transform = CGAffineTransformMakeRotation(30 * M_PI /180.0);
        item.likeImageView.alpha = [self _presentDirectionMarkImgeWithPoint:item.center];
        
    } completion:^(BOOL finished) {
        self.isMove = NO;
        [self _completionHandlerWithView:item];
        if (self.callbackView == nil) {
            if ([self.delegate respondsToSelector:@selector(cardDrapView:drapEndInIndex:)]) {
                [self.delegate cardDrapView:self drapEndInIndex:self.nowIndex];
            }
        }
        self.callbackView = nil;
        self.nowIndex++;
    }];
}

// call back last one right not call back  // 目前只支持左边划出，可以回滚，可自主修改
- (void)callbacRemovekItem {
    if (self.isMove || self.nowIndex - 1 < 0 || !self.drapView || self.direction == DrapDirectionRight) {
        return;
    }
    self.isMove = YES;
    CardDrapItem *item = (CardDrapItem *)[self createCallbackView];
    // 此处写自己的model
//    [item setValue:self.itemDataSource[self.nowIndex-1] forKey:@"model"];
    [item setValue:self.itemDataSource[self.nowIndex - 1] forKey:@"img"];
    item.userInteractionEnabled = YES;
    item.notLikeImageView.alpha = 0;
    item.likeImageView.alpha = 0;
    if (self.direction == DrapDirectionRight) {
        item.transform = CGAffineTransformMakeRotation(30 * M_PI/180.0);
        item.center = CGPointMake((UI_SCREEN_WIDTH + item.frame.size.width)/2, self->_originalCenter.y - 20);

    } else if (self.direction == DrapDirectionLeft) {
        item.transform = CGAffineTransformMakeRotation(-30 * M_PI/180.0);
        item.center = CGPointMake(-(UI_SCREEN_WIDTH + item.frame.size.width)/2, self->_originalCenter.y -20);
    }
    
    self.callbackView = item;
    self.drapView = nil;

    
    [UIView animateWithDuration:.3 animations:^{
        item.transform = CGAffineTransformMakeRotation(0);
        item.center = self->_originalCenter;
        [self insertSubview:item aboveSubview:self.subviews.lastObject];

        
    } completion:^(BOOL finished) {
        self.isMove = NO;
        [self dequeueReusableItemWithIdentifier:item.reuseIdentifier];
        self.nowIndex--;
    }];
}

- (void)_completionHandlerWithView:(UIView *)item {
//    if (!self.itemDataSource.count) {
//        return;
//    }
    
    self.drapView = item;
    [self.visibleViews removeObject:item];
    [self enqueueReusableView:item];
    [item removeFromSuperview];
    
    // TODO:滑动完成可以在此赋值下一段数据 根据自己要求
//    if (self.nowIndex + 1 < self.items.count) {
//        CardDrapItem *item = (CardDrapItem *)[self.items objectAtIndex:self.nowIndex];
//        [item setValue:self.itemDataSource[self.nowIndex + 1] forKey:@"model"];
//    }
    //TODO: 可以在此处加载新的数据 根据自己需求
//    if ((self.nowIndex + 1) / self.everyCount == 1  && self.everyCount != 0) {
//        [self reloadData];
//    }
    
    for (CardDrapItem *otherItem in self.visibleViews) {
        otherItem.userInteractionEnabled = YES;
    }
}

- (CGFloat)_presentDirectionMarkImgeWithPoint:(CGPoint)point {
    CGFloat alpha = 0;
    if (self.direction == DrapDirectionLeft) {
        alpha = 1 - (point.x / self.frame.size.width);
    } else if(self.direction == DrapDirectionRight) {
        alpha = point.x / self.frame.size.width;
    }
    return alpha;
}

- (void)_noDataAlter {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isLoading = YES;
        if ([self.delegate respondsToSelector:@selector(alterNoDataWithcardDrapView:)]) {
            [self.delegate alterNoDataWithcardDrapView:self];
        }
    });
}

- (NSInteger)currentIndex {
    return self.nowIndex;
}

- (NSMutableDictionary *)itemCache {
    if (_itemCache == nil) {
        _itemCache = [NSMutableDictionary dictionary];
    }
    return _itemCache;
}

- (NSMutableDictionary<NSString *,NSMutableSet *> *)reuseViews {
    if (_reuseViews == nil) {
        _reuseViews = [NSMutableDictionary dictionary];
    }
    return _reuseViews;
}

- (NSMutableSet<UIView *> *)visibleViews {
    if (_visibleViews == nil) {
        _visibleViews = [NSMutableSet set];
    }
    return _visibleViews;
}

- (NSMutableArray<UIView *> *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (NSMutableArray *)itemDataSource {
    if (_itemDataSource == nil) {
        _itemDataSource = [NSMutableArray array];
    }
    return _itemDataSource;
}


- (UIImageView *)placeHolderImgView {
    if (_placeHolderImgView == nil) {
        _placeHolderImgView = [UIImageView new];
        _placeHolderImgView.image = [UIImage imageNamed:@""];
        _placeHolderImgView.contentMode = UIViewContentModeScaleAspectFill;
        _placeHolderImgView.image = [UIImage imageNamed:@"m_user_ic"];
        _placeHolderImgView.layer.masksToBounds = YES;
        _placeHolderImgView.layer.cornerRadius = 15;
    }
    return _placeHolderImgView;
}

@end

static char kAssociateObjectKey;

@implementation UIView (Drap)

- (NSString *)reuseIdentifier {
    return objc_getAssociatedObject(self, &kAssociateObjectKey);
}

- (void)setReuseIdentifier:(NSString *)reuseIdentifier {
    objc_setAssociatedObject(self, &kAssociateObjectKey, reuseIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

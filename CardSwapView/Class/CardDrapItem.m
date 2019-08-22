//
//  CardDrapItem.m

//
//  Created by slash on 2019/8/1.
//  Copyright © 2019 slash. All rights reserved.
//

#import "CardDrapItem.h"
#import <Masonry.h>

@interface CardDrapItem ()
// <#type#>
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation CardDrapItem

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.imgView];
    [self.contentView addSubview:self.notLikeImageView];
    [self.contentView addSubview:self.likeImageView];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.notLikeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10);
        make.left.equalTo(self.contentView).offset(10);
    }];
    
    [self.likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.contentView).offset(-10);
    }];
}

- (void)setImg:(NSString *)img {
    if (img) {
        self.imgView.image = [UIImage imageNamed:img];
    }
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [UIView new];
    }
    return _contentView;
}

- (UIImageView *)notLikeImageView {
    if (_notLikeImageView == nil) {
        _notLikeImageView = [UIImageView new];
        _notLikeImageView.image = [UIImage imageNamed:@"m_btn_pass"];
        _notLikeImageView.alpha = 0.0;
    }
    return _notLikeImageView;
}

- (UIImageView *)likeImageView {
    if (_likeImageView == nil) {
        _likeImageView = [UIImageView new];
        _likeImageView.image = [UIImage imageNamed:@"m_btn_like"];
        _likeImageView.alpha = 0.0;
    }
    return _likeImageView;
}

- (UIImageView *)imgView {
    if (_imgView == nil) {
        _imgView = [UIImageView new];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
    }
    return _imgView;
}

@end

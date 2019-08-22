//
//  CardDrapItem.h

//
//  Created by slash on 2019/8/1.
//  Copyright © 2019 slash. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardDrapItem : UIView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
// <#type属性#>
@property (nonatomic, strong) UIView *contentView;
// <#type属性#>
@property (nonatomic, strong) UIImageView *likeImageView;
// <#type属性#>
@property (nonatomic, strong) UIImageView *notLikeImageView;
// <#type#>
@property (nonatomic, copy) NSString *img;

@end

NS_ASSUME_NONNULL_END

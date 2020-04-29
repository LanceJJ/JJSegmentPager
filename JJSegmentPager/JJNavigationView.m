//
//  JJNavigationView.m
//  JJSegmentPager
//
//  Created by Lance on 2020/4/29.
//  Copyright © 2020 Lance. All rights reserved.
//

#import "JJNavigationView.h"

@interface JJNavigationView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation JJNavigationView


- (IBAction)backAction:(id)sender {
    
    if (self.backBlock) {
        self.backBlock();
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

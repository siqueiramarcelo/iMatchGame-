//
//  gameButton.m
//  testButtonGrid
//
//  Created by Marcelo on 3/17/14.
//  Copyright (c) 2014 Marcelo Siqueira. All rights reserved.
//

#import "gameButton.h"

@implementation gameButton
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cardIndex = _cardIndex;
    }
    return self;
}
*/
- (id)initWithId:(NSString *)cardIndex {
    
    self = [super init];
    
    if (self) {
        
        self.cardIndex = cardIndex;
        self.cardCoverImage = [UIImage imageNamed:@"cover2.png"];
        
        CGRect cardCoverFrame = CGRectMake(0, 0, 90, 90);
        self.cardCoverView = [[UIImageView alloc] initWithFrame:cardCoverFrame];
        self.cardCoverView.image = self.cardCoverImage;
        [self addSubview:self.cardCoverView];
        
    }
    
    return self;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

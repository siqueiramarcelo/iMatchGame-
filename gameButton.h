//
//  gameButton.h
//  testButtonGrid
//
//  Created by Marcelo on 3/17/14.
//  Copyright (c) 2014 Marcelo Siqueira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gameButton : UIButton

@property (strong, nonatomic)NSString *cardIndex;

- (id)initWithId:(NSString *)cardIndex;

@property (strong, nonatomic)UIImageView *cardCoverView;
@property (strong, nonatomic)UIImage *cardCoverImage;
@property (assign, nonatomic)BOOL isAlreadyMatched;

@end

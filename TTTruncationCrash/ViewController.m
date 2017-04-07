//
//  ViewController.m
//  TTTruncationCrash
//
//  Created by Alex Figueroa on 2017-04-07.
//  Copyright © 2017 Alex Figueroa. All rights reserved.
//

#import "ViewController.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface ViewController ()

@property (nonatomic, strong) TTTAttributedLabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.label.attributedText = [[NSAttributedString alloc] initWithString:@"EH\n\n\n\nCanada"];
    NSDictionary *tokenAttributes = @{NSLinkAttributeName: [NSURL URLWithString:@"alex"]};
    self.label.attributedTruncationToken = [[NSAttributedString alloc] initWithString:@"...more"
                                                                           attributes:tokenAttributes];
    [self.view addSubview:self.label];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSDictionary<NSString *, UIView *> *views = @{@"label": self.label};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(100)-[label]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

#pragma mark - Views

- (TTTAttributedLabel *)label {
    if (!_label) {
        _label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _label.numberOfLines = 3;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.backgroundColor = [UIColor lightGrayColor];
    }
    
    return _label;
}


@end

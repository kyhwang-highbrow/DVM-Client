//
//  KCAsyncImageView.h
//
//  Created by Insoo Kim on 3/30/12.
//  Copyright (c) 2012 Kakao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KCAsyncImageViewDelegate;

@interface KCAsyncImageView : UIImageView

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, unsafe_unretained) id<KCAsyncImageViewDelegate> delegate;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic) BOOL showActivityIndicator;
@property (nonatomic) UIActivityIndicatorViewStyle activityIndicatorStyle;
@property (nonatomic) BOOL fadeInImages;
@property (nonatomic) NSTimeInterval fadeInDuration;
@property (nonatomic) BOOL progressiveDownload;

@end

@protocol KCAsyncImageViewDelegate <NSObject>

@optional

- (void)asyncImageViewDidStartLoading:(KCAsyncImageView *)asyncImageView;
- (void)asyncImageViewDidFinishLoading:(KCAsyncImageView *)asyncImageView;
- (void)asyncImageView:(KCAsyncImageView *)asyncImageView didFailWithError:(NSError *)error;

@end
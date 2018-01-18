//
//  VideoM.m
//  学习视频播放
//
//  Created by mac  on 2018/1/15.
//  Copyright © 2018年 mac . All rights reserved.
//

#import "VideoM.h"

@implementation VideoM

+ (instancetype)videoWithPath:(NSString *)path title:(NSString *)title fileAttr:(NSDictionary *)fileAttr{
    VideoM *video = [[self alloc] init];
    video.path = path;
    video.title = title;
    video.fileAttr = fileAttr;
    return video;
}

@end

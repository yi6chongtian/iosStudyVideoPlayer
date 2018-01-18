//
//  VideoM.h
//  学习视频播放
//
//  Created by mac  on 2018/1/15.
//  Copyright © 2018年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoM : NSObject

@property (nonatomic,copy) NSString *path;

@property (nonatomic,copy) NSString *title;

@property (nonatomic,strong) NSDictionary *fileAttr;

+ (instancetype)videoWithPath:(NSString *)path title:(NSString *)title fileAttr:(NSDictionary *)fileAttr;

@end

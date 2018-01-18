//
//  ViewController.m
//  学习视频播放
//
//  Created by mac  on 2018/1/15.
//  Copyright © 2018年 mac . All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@property (nonatomic,strong) MPMoviePlayerController *mpControl;

@property (nonatomic,strong) MPMoviePlayerViewController *mpVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //监听当前视频播放状态
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
//    [self playWithMovieplayController:nil];
    
    [self playWithMPMoviePlayerViewController:nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 播放视频

#pragma mark - 使用MPMoviePlayerController播放

- (void)playWithMovieplayController:(NSString *)path{
    if(path == nil){
         path = [[NSBundle mainBundle] pathForResource:@"行尸走肉" ofType:@"mp4"];
    }
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if([fileMgr fileExistsAtPath:path]){
        self.mpControl.contentURL = [NSURL fileURLWithPath:path];
        [self.mpControl prepareToPlay];
    }
}

#pragma mark - 使用MPMoviePlayerViewController播放

- (void)playWithMPMoviePlayerViewController:(NSString *)path{
    if(path == nil){
        path = [[NSBundle mainBundle] pathForResource:@"行尸走肉" ofType:@"mp4"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
        [self presentMoviePlayerViewControllerAnimated:vc];
        vc.moviePlayer.view.frame = self.view.bounds;
        [vc.moviePlayer prepareToPlay];
        [vc.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.frame = self.view.bounds;
    });
}

#pragma mark - Notification function

-(void)endPlay
{
    NSLog(@"播放结束");
}

-(void)loadStateDidChange:(NSNotification*)sender
{
    switch (self.mpControl.loadState) {
        case MPMovieLoadStatePlayable:
        {
            NSLog(@"加载完成,可以播放");
        }
            break;
        case MPMovieLoadStatePlaythroughOK:
        {
            NSLog(@"缓冲完成，可以连续播放");
        }
            break;
        case MPMovieLoadStateStalled:
        {
            NSLog(@"缓冲中");
        }
            break;
        case MPMovieLoadStateUnknown:
        {
            NSLog(@"未知状态");
        }
            break;
        default:
            break;
    }
}



#pragma mark - Getter

- (MPMoviePlayerController *)mpControl{
    if(_mpControl == nil){
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] init];
        player.fullscreen = NO;
        player.scalingMode = MPMovieScalingModeAspectFit;
        player.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
        [self.view addSubview:player.view];
        player.movieSourceType = MPMovieSourceTypeFile;
        player.shouldAutoplay = YES;
        _mpControl = player;
    }
    return _mpControl;
}


@end

//
//  VideoListTableViewController.m
//  学习视频播放
//
//  Created by mac  on 2018/1/15.
//  Copyright © 2018年 mac . All rights reserved.
//

#import "VideoListTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface VideoListTableViewController ()

@property (nonatomic,strong) NSMutableArray *videlList;

@end

@implementation VideoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videlList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    VideoM *video = [self.videlList objectAtIndex:indexPath.row];
    cell.textLabel.text = video.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     VideoM *video = [self.videlList objectAtIndex:indexPath.row];
    //[self playWithMPMoviePlayerViewController:video.path];
    [self playWithAVPlayerViewController:video.path];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 使用MPMoviePlayerViewController播放

- (void)playWithMPMoviePlayerViewController:(NSString *)path{
    if(path == nil){
        return;
    }
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    [self presentMoviePlayerViewControllerAnimated:vc];
    vc.moviePlayer.view.frame = self.view.bounds;
    [vc.moviePlayer prepareToPlay];
    [vc.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.view.frame = self.view.bounds;
    [[NSNotificationCenter defaultCenter]addObserver:self
     
                                           selector:@selector(movieFinishedCallback:)
     
                                               name:MPMoviePlayerPlaybackDidFinishNotification
     
                                             object:vc.moviePlayer];
}

#pragma mark - 使用AVPlayerViewController播放

- (void)playWithAVPlayerViewController:(NSString *)path{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;
    AVPlayerViewController *playVC = [[AVPlayerViewController alloc] init];
    playVC.showsPlaybackControls = YES;
    playVC.player = player;
    [self presentViewController:playVC animated:YES completion:^{
        [player play];
    }];
    //把AVPlayerViewController的view添加到UIViewController的view中
    //[self.view addSubview:playVC.view];
//    [[UIApplication sharedApplication].keyWindow addSubview:playVC.view];
//    playVC.view.frame = [UIScreen mainScreen].bounds;
}

#pragma mark - 播放通知
-(void)movieFinishedCallback:(NSNotification*)notify{

    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];

    [[NSNotificationCenter defaultCenter]removeObserver:self
 
                                              name:MPMoviePlayerPlaybackDidFinishNotification
 
                                            object:theMovie];

    [self dismissMoviePlayerViewControllerAnimated];

}

#pragma mark - Getter

- (NSMutableArray *)videlList{
    if(_videlList == nil){
        NSMutableArray *arr = [NSMutableArray array];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray *subPaths = [fileMgr subpathsAtPath:self.video.path];
        for (NSString *file in subPaths) {
            BOOL isDir;
            NSString *filePath = [self.video.path stringByAppendingPathComponent:file];
            BOOL exist = [fileMgr fileExistsAtPath:filePath isDirectory:&isDir];
            if(exist && !isDir){
                NSLog(@"file");
                NSError *error;
                NSDictionary *dict = [fileMgr attributesOfItemAtPath:filePath error:&error];
                if(error){
                    NSLog(@"error:%@",error);
                }else{
                    NSLog(@"dict:%@",dict);
                }
                VideoM *v = [VideoM videoWithPath:filePath title:file fileAttr:dict];
                [arr addObject:v];
            }
        }
        _videlList = arr;
        //排序
         NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];//Z:时区
        [_videlList sortUsingComparator:^NSComparisonResult(VideoM *  _Nonnull obj1, VideoM *  _Nonnull obj2) {
            NSDate *date1 = obj1.fileAttr[NSFileCreationDate];
            NSDate *date2 = obj2.fileAttr[NSFileCreationDate];
            //NSDate *date1 = [dateFormat dateFromString:strCreateDate1];
            //NSDate *date1 = [dateFormat dateFromString:strCreateDate2];
            return [date1 compare:date2];
        }];
    }
    return _videlList;
}

@end

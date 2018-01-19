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

@property (nonatomic,assign) AVPlayerViewController *playVC;

@property (nonatomic,assign) UILabel *timeLabel;

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
    UILabel *timeLb = [UILabel new];
    timeLb.textAlignment = NSTextAlignmentCenter;
    timeLb.textColor = [UIColor greenColor];
    timeLb.font = [UIFont systemFontOfSize:20];
    timeLb.frame = CGRectMake(0, 64,self.view.bounds.size.width, 100);
    timeLb.backgroundColor = [UIColor clearColor];
    [playVC.contentOverlayView addSubview:timeLb];
    self.timeLabel = timeLb;
    self.playVC = playVC;
    playVC.showsPlaybackControls = YES;
    playVC.player = player;
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:playVC];
    navi.navigationBar.hidden = YES;
    playVC.navigationController.navigationBar.hidden = YES;
    [self presentViewController:navi animated:YES completion:^{
        [player play];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [playVC.contentOverlayView addGestureRecognizer:pan];
        [playVC.view addGestureRecognizer:pan];
    }];
}

- (void)pan:(UIPanGestureRecognizer *)panGes{
    NSLog(@"%s",__func__);
    static NSInteger totalTime = 0;
    if(self.playVC){
        if(panGes.state == UIGestureRecognizerStateBegan){
            self.timeLabel.hidden = NO;
            totalTime = 0;
        }else if (panGes.state == UIGestureRecognizerStateChanged){
            AVPlayer *player = self.playVC.player;
            CGPoint point = [panGes translationInView:panGes.view];
            totalTime += point.x;
            NSInteger currentTime = player.currentTime.value / player.currentTime.timescale;
            CMTime time = CMTimeMake(currentTime + totalTime, 1);
            [player seekToTime:time];
            self.timeLabel.text = [self intToTime:time.value / time.timescale];
        }else{
            totalTime = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.timeLabel.hidden = YES;
            }];
        }
        
    }
    [panGes setTranslation:CGPointZero inView:panGes.view];
}

- (NSString *)intToTime:(NSInteger)intTime{
    NSInteger min = intTime / 60;
    NSInteger second = intTime % 60;
    return [NSString stringWithFormat:@"%zd:%zd",min,second];
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

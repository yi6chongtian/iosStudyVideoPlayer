//
//  VideoDirTableViewController.m
//  学习视频播放
//
//  Created by mac  on 2018/1/15.
//  Copyright © 2018年 mac . All rights reserved.
//

#import "VideoDirTableViewController.h"
#import "VideoM.h"
#import "VideoListTableViewController.h"

@interface VideoDirTableViewController ()

@property (nonatomic,strong) NSMutableArray *dirList;

@end

@implementation VideoDirTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dirList];
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
    return self.dirList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    VideoM *v = [self.dirList objectAtIndex:indexPath.row];
    cell.textLabel.text = v.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
    [self performSegueWithIdentifier:@"segVideo" sender:self];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segVideo"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        VideoM *v = [self.dirList objectAtIndex:indexPath.row];
        VideoListTableViewController *vc = segue.destinationViewController;
        vc.video = v;
    }
}


#pragma mark - Getter

- (NSMutableArray *)dirList{
    if(_dirList == nil){
        NSMutableArray *arr = [NSMutableArray array];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error;
        NSArray *subPaths = [fileMgr subpathsAtPath:kIosDir];
        for (NSString *file in subPaths) {
            BOOL isDir;
            BOOL exist = [fileMgr fileExistsAtPath:[kIosDir stringByAppendingPathComponent:file] isDirectory:&isDir];
            if(exist && isDir){
                NSLog(@"isDir");
                VideoM *v = [VideoM videoWithPath:[kIosDir stringByAppendingPathComponent:file] title:file fileAttr:nil];
                [arr addObject:v];
            }
        }
        _dirList = arr;
    }
    return _dirList;
}

@end

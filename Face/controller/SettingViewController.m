//
//  SettingViewController.m
//  Face
//
//  Created by 杨朋亮 on 2/11/14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *cellTitleArray;
@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate  = self;
    self.cellTitleArray = @[ @[@"关于"],
                             @[@"个人资讯",@"会话设置"],
                             @[@"网络状态"],
                             @[@"清除所有对话记录"],
                             ];
    
//    self.historys = [[NSMutableArray alloc] initWithArray: [[HistoryDB instance] loadHistoryDB]];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [self.cellTitleArray count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [self.cellTitleArray objectAtIndex:section];
    return [array count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *historyStr = @"historyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:historyStr];
    }
//    History *history = [self.historys objectAtIndex:indexPath.row];
    
//    IMUser *theUser =  [[UserDB instance] loadUser:history.peerUID];
   NSArray *array = [self.cellTitleArray objectAtIndex:indexPath.section];
    [cell.textLabel setText:[array objectAtIndex:indexPath.row]];
    
    
    
    
    return cell;
    
}
#pragma mark - UITableViewDelegate


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

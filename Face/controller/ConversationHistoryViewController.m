//
//  ConversationHistoryViewController.m
//  Face
//
//  Created by 杨朋亮 on 2/11/14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "ConversationHistoryViewController.h"
#import "History.h"
#import "HistoryDB.h"
#import  "UserDB.h"
#import "User.h"
#import "PublicFunc.h"

@interface ConversationHistoryViewController ()

@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *historys;

@end

@implementation ConversationHistoryViewController

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
    
    self.historys = [[NSMutableArray alloc] initWithArray: [[HistoryDB instance] loadHistoryDB]];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return [self.historys count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *historyStr = @"historyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyStr];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:historyStr];
    }
    History *history = [self.historys objectAtIndex:indexPath.row];
    
    int callDuration = history.endTimestamp - history.beginTimestamp;
    
    NSString *durationStr = [NSString stringWithFormat:@"通话时长:%@",[PublicFunc getTimeStrFromSeconds:callDuration]];
    
    IMUser *theUser =  [[UserDB instance] loadUser:history.peerUID];
    
    [cell.textLabel setText:@"asdfasdf"];
    [cell.detailTextLabel setText:durationStr];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    
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

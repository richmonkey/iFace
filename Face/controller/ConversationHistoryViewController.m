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
#import "HistoryTableViewCell.h"

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

-(void)viewDidAppear:(BOOL)animated{
    if (self.historys) {
        [self.historys removeAllObjects];
        self.historys = nil;
    }
    self.historys = [[NSMutableArray alloc] initWithArray: [[HistoryDB instance] loadHistoryDB]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.historys count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   // HistoryTableViewCell
    static NSString *historyStr = @"historyCell";
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:historyStr];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"HistoryTableViewCell" owner:self options:nil] lastObject];
    }
    History *history = [self.historys objectAtIndex:indexPath.row];
    
    int callDuration = history.endTimestamp - history.beginTimestamp;
    NSString *durationStr = [NSString stringWithFormat:@"通话时长:%@",[PublicFunc getTimeStrFromSeconds:callDuration]];
    [cell.durationLabel setText:durationStr];
    
    IMUser *theUser =  [[UserDB instance] loadUser:history.peerUID];
    if (!theUser) {
        [cell.nameLabel setText:@"未知用户"];
    }else{
        [cell.nameLabel setText:theUser.displayName];
    }
    
    bool isOut          = history.flag|FLAG_OUT;
    bool isCancel       = history.flag|FLAG_CANCELED;
    bool isRefused      = history.flag|FLAG_REFUSED;
    bool isAccepted     = history.flag|FLAG_ACCEPTED;
    bool isUnreceived   = history.flag|FLAG_UNRECEIVED;
    
    if (isOut) {
        [cell.iconView setImage:[UIImage imageNamed:@"callOutIcon"]];
        if(isCancel) {
            [cell.statusLabel setTextColor:[UIColor grayColor]];
            [cell.statusLabel setText:@"取消"];
        }else if(isRefused) {
            [cell.statusLabel setTextColor:[UIColor redColor]];
            [cell.statusLabel setText:@"被拒绝"];
        }else if(isAccepted){
            [cell.statusLabel setTextColor:[UIColor greenColor]];
            [cell.statusLabel setText:@"通话成功"];
        }else if(isUnreceived){
            [cell.statusLabel setTextColor:[UIColor blueColor]];
            [cell.statusLabel setText:@"未接听"];
        }
    }else{
         [cell.iconView setImage:[UIImage imageNamed:@"callInIcon"]];
        if(isCancel) {
            [cell.statusLabel setTextColor:[UIColor grayColor]];
            [cell.statusLabel setText:@"取消"];
        }else if(isRefused) {
            [cell.statusLabel setTextColor:[UIColor redColor]];
            [cell.statusLabel setText:@"被拒绝"];
        }else if(isAccepted){
            [cell.statusLabel setTextColor:[UIColor greenColor]];
            [cell.statusLabel setText:@"通话成功"];
        }else if(isUnreceived){
            [cell.statusLabel setTextColor:[UIColor blueColor]];
            [cell.iconView setImage:[UIImage imageNamed:@"callInNotAnswerIcon"]];
            [cell.statusLabel setText:@"未接听"];
        }
    }


    
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

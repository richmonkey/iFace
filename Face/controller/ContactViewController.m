//
//  ContactViewController.m
//  Message
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "ContactViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "UserDB.h"
#import "UIImageView+Letters.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
#import "ContactHeaderView.h"
#import "ContactIMUserTableViewCell.h"
#import "ContactPhoneTableViewCell.h"
#import "VOIPViewController.h"
#import "UIView+Toast.h"
#import "IMService.h"

/*
 ----------
 tableheaderView
 名字
 字母简写
 职务
 公司
 
 ----------
 cell
 头像 电话类型
    电话
 ------
 cell
     自定义状态                      最后上线时间
 
 ----------
 tablebottomview
 发送信息
 
 */



@interface ContactViewController ()



@end

@implementation ContactViewController

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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableview = [[UITableView alloc] initWithFrame:rect style: UITableViewStyleGrouped];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
    
    ContactHeaderView *headerView = [[[NSBundle mainBundle]loadNibNamed:@"ContactHeaderView" owner:self options:nil] lastObject];
    
    
    [self.tableview setTableHeaderView: headerView];
    
    if (self.contact.contactName && [self.contact.contactName length]!= 0) {
        [headerView.nameLabel setText:self.contact.contactName];
    }else{
       [headerView.nameLabel setText:@" "];
    }
   
    [self handleHeadViewImage:headerView];
    
    if ([self getUserCount] > 0) {
  
        rect = CGRectMake(0, 0, self.view.frame.size.width, 50);
        self.sendIMBtn = [[UIButton  alloc] initWithFrame: rect];
        [self.sendIMBtn setBackgroundColor:RGBACOLOR(47, 174, 136, 0.9f)];
        [self.sendIMBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.sendIMBtn setTitle:@"呼叫" forState:UIControlStateNormal];
        [self.sendIMBtn setTitleColor:RGBACOLOR(239, 239, 239, 1.0f) forState:UIControlStateNormal];
        
        [self.sendIMBtn addTarget:self action:@selector(onSendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.tableview setTableFooterView: self.sendIMBtn];
    }
 }


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self getUserCount] > 0) {
        return [self getUserCount];
    } else {
        return [self.contact.phoneDictionaries count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self getUserCount] > 0) {

        ContactIMUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactIMUserTableViewCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContactIMUserTableViewCell" owner:self options:nil] lastObject];
        }
        
        IMUser *u = [self.contact.users objectAtIndex:indexPath.row];
        [cell.phoneNumberLabel setText:u.phoneNumber.number];
        if (u.state.length > 0) {
            [cell.personnalStatusLabel setText:u.state];
        }else{
            [cell.personnalStatusLabel setText:@"~没有状态~"];
        }
        return cell;
    } else {
        ContactPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactPhoneTableViewCell"];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ContactPhoneTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *phoneDic = [self.contact.phoneDictionaries objectAtIndex:indexPath.row];
        [cell.phoneNumLabel setText:[phoneDic objectForKey:@"value"]];
        [cell.phoneTypeLabel setText:[phoneDic objectForKey:@"label"]];
        
        return cell;
        
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}

-(NSInteger)getUserCount{
    return [self.contact.users count];
}


-(void)onSendMessage {
    
    if ([self.contact.users count] == 1) {
        
        NSLog(@"send message");
        User *u = [self.contact.users objectAtIndex:0];
        [self phoneingByUser:u];
        
    } else if ([self.contact.users count] > 1) {
        if (self.contact.users.count == 2) {
            User *u0 = [self.contact.users objectAtIndex:0];
            User *u1 = [self.contact.users objectAtIndex:1];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:u0.phoneNumber.number, u1.phoneNumber.number, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        } else if (self.contact.users.count == 3) {
            User *u0 = [self.contact.users objectAtIndex:0];
            User *u1 = [self.contact.users objectAtIndex:1];
            User *u2 = [self.contact.users objectAtIndex:2];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:u0.phoneNumber.number, u1.phoneNumber.number, u2.phoneNumber.number, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        } else {
            User *u0 = [self.contact.users objectAtIndex:0];
            User *u1 = [self.contact.users objectAtIndex:1];
            User *u2 = [self.contact.users objectAtIndex:2];
            User *u3 = [self.contact.users objectAtIndex:3];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:u0.phoneNumber.number, u1.phoneNumber.number, u2.phoneNumber.number, u3.phoneNumber.number, nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            [actionSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSAssert(buttonIndex < self.contact.users.count, @"");
   User *u = [self.contact.users objectAtIndex:buttonIndex];
    [self phoneingByUser:u];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) handleHeadViewImage:(ContactHeaderView *)headerView{
    if ([self.contact.users count] > 0) {
        for(IMUser* usr in self.contact.users) {
            if (usr.avatarURL.length > 0) {
               [headerView.headView sd_setImageWithURL:[[NSURL alloc] initWithString:usr.avatarURL] placeholderImage:[UIImage imageNamed:@"PersonalChat"]];
            }
        }
    }else{
        if (self.contact.contactName && [self.contact.contactName length]!= 0) {
            NSString *nameChars;
            if([self.contact.contactName length] >= 2){
                nameChars = [NSString stringWithFormat:@"%c %c",pinyinFirstLetter([self.contact.contactName characterAtIndex:0]),pinyinFirstLetter([self.contact.contactName characterAtIndex:1])];
            }else if([self.contact.contactName length] == 1){
                nameChars = [NSString stringWithFormat:@"%c",pinyinFirstLetter([self.contact.contactName characterAtIndex:0])];
            }
            [headerView.headView setImageWithString:nameChars];
        }
    }
}
/**
 *  拨打电话
 *
 *  @param user User
 */
-(void)phoneingByUser:(User*)user{
    if ([[IMService instance] connectState] == STATE_CONNECTED) {
        VOIPViewController *controller = [[VOIPViewController alloc] initWithCalledUID:user.uid];
        [self presentViewController:controller animated:YES completion:nil];
    }else if([[IMService instance] connectState] == STATE_CONNECTING){
        [self.tabBarController.view makeToast:@"正在连接,请稍等" duration:2.0f position:@"bottom"];
    }else if([[IMService instance] connectState] == STATE_UNCONNECTED){
        [self.tabBarController.view makeToast:@"连接出错,请检查" duration:2.0f position:@"bottom"];
    }
}

@end

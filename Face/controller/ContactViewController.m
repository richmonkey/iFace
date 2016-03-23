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
#import "VOIPVoiceViewController.h"
#import "VOIPVideoViewController.h"
#import "UIView+Toast.h"

#import "DailCompView.h"


#import <voipsession/VOIPService.h>

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
typedef enum {
    ConnectVoiceType,
    ConnectVideoType
} ConnectType;


@interface ContactViewController ()

@property (strong,nonatomic) DailCompView *dailView;
@property ConnectType nowContType;

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
    
    self.title = @"详细资料";
    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    
    ContactHeaderView *headerView = [ContactHeaderView fromXib];
    
    
    [self.tableview setTableHeaderView: headerView];
    
    if (self.contact.contactName && [self.contact.contactName length]!= 0) {
        [headerView.nameLabel setText:self.contact.contactName];
    }else{
       [headerView.nameLabel setText:@" "];
    }
   
    [self handleHeadViewImage:headerView];
    
    if ([self getUserCount] > 0) {
        
        self.dailView = [DailCompView fromXib];
        [self.dailView.voiceBtn addTarget:self action:@selector(onSendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.dailView.videoBtn addTarget:self action:@selector(onSendMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tableview setTableFooterView: self.dailView];
        
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
            cell = [ContactIMUserTableViewCell fromXib];
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
            cell = [ContactPhoneTableViewCell fromXib];
        }
        NSDictionary *phoneDic = [self.contact.phoneDictionaries objectAtIndex:indexPath.row];
        [cell.phoneNumLabel setText:[phoneDic objectForKey:@"value"]];
        [cell.phoneTypeLabel setText:[phoneDic objectForKey:@"label"]];
        
        return cell;
        
    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 138;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中项
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

-(NSInteger)getUserCount{
    return [self.contact.users count];
}


-(void)onSendMessage:(id)sender {
    
    
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == kDailVideoBtnTag) {
        self.nowContType = ConnectVideoType;
    }else if(btn.tag == kDailVoiceBtnTag){
        self.nowContType = ConnectVoiceType;
    }
    
    if ([self.contact.users count] == 1) {
        
        NSLog(@"send message");
        User *u = [self.contact.users objectAtIndex:0];
        [self phoneingByUser:u andConnectType:self.nowContType];
        
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
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSAssert(buttonIndex < self.contact.users.count, @"");
    User *u = [self.contact.users objectAtIndex:buttonIndex];
    [self phoneingByUser:u andConnectType:self.nowContType];
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
-(void)phoneingByUser:(User*)user andConnectType:(ConnectType)type{
    if ([[VOIPService instance] connectState] == STATE_CONNECTED) {
        switch (type) {
            case ConnectVideoType:
            {
                VOIPVideoViewController*controller = [[VOIPVideoViewController alloc] initWithCalledUID:user.uid];
                [self presentViewController:controller animated:YES completion:nil];
            }
                break;
            case ConnectVoiceType:
            {
                VOIPVoiceViewController *controller = [[VOIPVoiceViewController alloc] initWithCalledUID:user.uid];
                [self presentViewController:controller animated:YES completion:nil];
            }
                break;
                
            default:
                break;
        }
    }else if([[VOIPService instance] connectState] == STATE_CONNECTING){
        [self.tabBarController.view makeToast:@"正在连接,请稍等" duration:2.0f position:@"bottom"];
    }else if([[VOIPService instance] connectState] == STATE_UNCONNECTED){
        [self.tabBarController.view makeToast:@"连接出错,请检查" duration:2.0f position:@"bottom"];
    }
}

@end

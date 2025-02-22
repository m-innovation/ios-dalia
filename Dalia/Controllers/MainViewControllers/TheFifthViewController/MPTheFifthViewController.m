//
//  MPTheFifthViewController.m
//  Misepuri
//
//  Created by M.Amatani on 2016/11/02.
//  Copyright © 2016年 Mobile Innovation. All rights reserved.
//

#import "MPTheFifthViewController.h"

@implementation MPTheFifthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //🔴contentView 高さ自動調整　幅自動調整
    [_contentView setAutoresizingMask: UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

    //XIB表示のため、contentViewを非表示
    [_contentView setHidden:YES];

    //load cell xib and attach with collectionView
    UINib *nib1 = [UINib nibWithNibName:@"TheFifth_nick_name_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib1 forCellReuseIdentifier:@"first_nickname_Identifier"];
    UINib *nib2 = [UINib nibWithNibName:@"TheFifth_gender_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib2 forCellReuseIdentifier:@"first_gender_Identifier"];
    UINib *nib3 = [UINib nibWithNibName:@"TheFifth_mail_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib3 forCellReuseIdentifier:@"first_mail_Identifier"];
    UINib *nib4 = [UINib nibWithNibName:@"TheFifth_job_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib4 forCellReuseIdentifier:@"first_job_Identifier"];
    UINib *nib5 = [UINib nibWithNibName:@"TheFifth_zipcode_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib5 forCellReuseIdentifier:@"first_zipcode_Identifier"];
    UINib *nib6 = [UINib nibWithNibName:@"TheFifth_address_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib6 forCellReuseIdentifier:@"first_address_Identifier"];
    UINib *nib7 = [UINib nibWithNibName:@"TheFifth_name_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib7 forCellReuseIdentifier:@"first_name_Identifier"];
    UINib *nib8 = [UINib nibWithNibName:@"TheFifth_furigana_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib8 forCellReuseIdentifier:@"first_furigana_Identifier"];
    UINib *nib9 = [UINib nibWithNibName:@"TheFifth_tel_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib9 forCellReuseIdentifier:@"first_tel_Identifier"];
    UINib *nib10 = [UINib nibWithNibName:@"TheFifth_generation_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib10 forCellReuseIdentifier:@"first_generation_Identifier"];
    UINib *nib11 = [UINib nibWithNibName:@"TheFifth_shop_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib11 forCellReuseIdentifier:@"first_shop_Identifier"];
    UINib *nib12 = [UINib nibWithNibName:@"TheFifth_birthday_TableViewCell" bundle:nil];
    [_tbl_userSetting registerNib:nib12 forCellReuseIdentifier:@"first_birthday_Identifier"];
    [_tbl_userSetting reloadData];

    _lbl_version.text =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    //お誕生日
    [txt_birthday setTintColor:[UIColor lightGrayColor]];

    if(txt_birthday.placeholder != nil){
        UIColor *color = [UIColor colorWithRed:124/255.0 green:123/255.0 blue:123/255.0 alpha:1.0];
        txt_birthday.attributedPlaceholder = [[NSAttributedString alloc] initWithString:txt_birthday.placeholder                                                                           attributes:@{ NSForegroundColorAttributeName:color }];
    }

    // キーボードアクション追加
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

    // キーボード表示を検知
    [nc addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];

    // キーボード収納を検知。
    [nc addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];

    //スイッチの縮小化
    sw_newsNotification.transform = CGAffineTransformMakeScale(0.9, 0.9);
    sw_curpon.transform = CGAffineTransformMakeScale(0.9, 0.9);
}

- (void)viewWillAppear:(BOOL)animated {

    //🔴標準navigation
    [self setHidden_BasicNavigation:YES];
    [self setImage_BasicNavigation:nil];
    [self setHiddenBackButton:YES];

    //🔴カスタムnavigation
    [self setHidden_CustomNavigation:NO];
    [self setImage_CustomNavigation:[UIImage imageNamed:@"header_ttl_setting.png"] imagePosition:1];

    //🔴タブの表示
    [(MPTabBarViewController*)[self.navigationController parentViewController] setHidden_Tab:NO];

    //選択タブ解除
    [(MPTabBarViewController*)[self.navigationController parentViewController] selectTab:4];

    [super viewWillAppear:animated];

    //会員情報保存項目取得
    [[ManagerDownload sharedInstance] getMemberInfo:[Utility getAppID] withDeviceID:[Utility getDeviceID] wirhCall:@"0" delegate:self];
}

- (void)viewDidAppear:(BOOL)animated {

    _scr_rootview.delegate = self;

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

    _scr_rootview.delegate = nil;

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

-(void)viewDidLayoutSubviews {

    [super viewDidLayoutSubviews];
}

#pragma mark - ScrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _scrollBeginingPoint = [scrollView contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGPoint currentPoint = [scrollView contentOffset];
    if(_scrollBeginingPoint.y < currentPoint.y){

        //下方向の時のアクション
        //カスタムトップナビゲーション　クローズ
        [self setFadeOut_CustomNavigation:true];

        //タブのクローズ
        [(MPTabBarViewController*)[self.navigationController parentViewController] setFadeOut_Tab:true];

    }else if(_scrollBeginingPoint.y ==0){

        //スクロール０
        //カスタムトップナビゲーション　オープン
        [self setFadeOut_CustomNavigation:false];

        //タブのオープン
        [(MPTabBarViewController*)[self.navigationController parentViewController] setFadeOut_Tab:false];

    }else if(_scrollBeginingPoint.y > currentPoint.y){

        //上方向の時のアクション
        //カスタムトップナビゲーション　オープン
        [self setFadeOut_CustomNavigation:false];

        //タブのオープン
        [(MPTabBarViewController*)[self.navigationController parentViewController] setFadeOut_Tab:false];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [memberObj.fld_colom count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 0;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(tableView == _tbl_userSetting){

        //ニックネーム
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"nick_name"]){

            cell_nick_name = [tableView dequeueReusableCellWithIdentifier:@"first_nickname_Identifier"];
            if(cell_nick_name == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_nick_name_TableViewCell" owner:self options:nil];
                cell_nick_name = [nib objectAtIndex:0];
            }
            cell_nick_name.txt_field.delegate = self;

            cell_nick_name.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_nick_name.fld_essential = YES;
            }else{

                cell_nick_name.fld_essential = NO;
            }

            cell_nick_name.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_nick_name.fld_essential == YES){

                cell_nick_name.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_nick_name.lbl_name.text];
            }
            
            cell_nick_name.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_nick_name.txt_field.text isEqualToString:@"<null>"]){

                cell_nick_name.txt_field.text = @"";
            }

            [cell_nick_name.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_nick_name;
        }

        //性別
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"gender"]){

            cell_gender = [tableView dequeueReusableCellWithIdentifier:@"first_gender_Identifier"];
            if(cell_gender == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_gender_TableViewCell" owner:self options:nil];
                cell_gender = [nib objectAtIndex:0];
            }
            cell_gender.txt_field.delegate = self;

            cell_gender.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_gender.fld_essential = YES;
            }else{

                cell_gender.fld_essential = NO;
            }

            cell_gender.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_gender.fld_essential == YES){

                cell_gender.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_gender.lbl_name.text];
            }

            cell_gender.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_gender.txt_field.text isEqualToString:@"<null>"]){

                cell_gender.txt_field.text = @"";
            }

            [cell_gender.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_gender;
        }

        //メール
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"mail"]){

            cell_mail = [tableView dequeueReusableCellWithIdentifier:@"first_mail_Identifier"];
            if(cell_mail == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_mail_TableViewCell" owner:self options:nil];
                cell_mail = [nib objectAtIndex:0];
            }
            cell_mail.txt_field.delegate = self;

            cell_mail.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_mail.fld_essential = YES;
            }else{

                cell_mail.fld_essential = NO;
            }

            cell_mail.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_mail.fld_essential == YES){

                cell_mail.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_mail.lbl_name.text];
            }

            cell_mail.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_mail.txt_field.text isEqualToString:@"<null>"]){

                cell_mail.txt_field.text = @"";
            }

            [cell_mail.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_mail;
        }

        //職業
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"job"]){

            cell_job = [tableView dequeueReusableCellWithIdentifier:@"first_job_Identifier"];
            if(cell_job == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_job_TableViewCell" owner:self options:nil];
                cell_job = [nib objectAtIndex:0];
            }
            cell_job.txt_field.delegate = self;

            cell_job.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_job.fld_essential = YES;
            }else{

                cell_job.fld_essential = NO;
            }

            cell_job.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_job.fld_essential == YES){

                cell_job.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_job.lbl_name.text];
            }

            cell_job.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_job.txt_field.text isEqualToString:@"<null>"]){

                cell_job.txt_field.text = @"";
            }

            [cell_job.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_job;
        }

        //郵便番号
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"zipcode"]){

            cell_zipcode = [tableView dequeueReusableCellWithIdentifier:@"first_zipcode_Identifier"];
            if(cell_zipcode == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_zipcode_TableViewCell" owner:self options:nil];
                cell_zipcode = [nib objectAtIndex:0];
            }
            cell_zipcode.txt_field.delegate = self;

            cell_zipcode.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_zipcode.fld_essential = YES;
            }else{

                cell_zipcode.fld_essential = NO;
            }

            cell_zipcode.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_zipcode.fld_essential == YES){

                cell_zipcode.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_zipcode.lbl_name.text];
            }

            cell_zipcode.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_zipcode.txt_field.text isEqualToString:@"<null>"]){

                cell_zipcode.txt_field.text = @"";
            }

            [cell_zipcode.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            //NumberPicker上部バー作成
            UIToolbar *numbaer_toolbar = [[UIToolbar alloc] init];
            numbaer_toolbar.backgroundColor = [UIColor whiteColor];
            numbaer_toolbar.frame=CGRectMake(0, 0, 320, 44);
            //DataPicker上部バーボタン設定
            UIBarButtonItem *numbaer_item0=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *numbaer_item1=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *numbaer_item2=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *numbaer_item3=[[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(zipcodeBtnClick)];
            numbaer_item3.tintColor = [UIColor blackColor];
            numbaer_toolbar.items=@[numbaer_item0,numbaer_item1,numbaer_item2,numbaer_item3];
            //DataPicker上部バー設定
            cell_zipcode.txt_field.inputAccessoryView = numbaer_toolbar;

            return cell_zipcode;
        }

        //住所
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"address"]){

            cell_address = [tableView dequeueReusableCellWithIdentifier:@"first_address_Identifier"];
            if(cell_address == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_address_TableViewCell" owner:self options:nil];
                cell_address = [nib objectAtIndex:0];
            }
            cell_address.txt_field.delegate = self;

            cell_address.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_address.fld_essential = YES;
            }else{

                cell_address.fld_essential = NO;
            }

            cell_address.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_address.fld_essential == YES){

                cell_address.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_address.lbl_name.text];
            }

            cell_address.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_address.txt_field.text isEqualToString:@"<null>"]){

                cell_address.txt_field.text = @"";
            }

            [cell_address.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_address;
        }

        //名前
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"name1"]){

            cell_name = [tableView dequeueReusableCellWithIdentifier:@"first_name_Identifier"];
            if(cell_name == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_name_TableViewCell" owner:self options:nil];
                cell_name = [nib objectAtIndex:0];
            }
            cell_name.txt_field1.delegate = self;
            cell_name.txt_field2.delegate = self;

            cell_name.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_name.fld_essential = YES;
            }else{

                cell_name.fld_essential = NO;
            }

            cell_name.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_name.fld_essential == YES){

                cell_name.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_name.lbl_name.text];
            }

            cell_name.txt_field1.text = [Utility checkNULL:[[memberObj.fld_value objectAtIndex:indexPath.row] objectAtIndex:0]];
            cell_name.txt_field2.text = [Utility checkNULL:[[memberObj.fld_value objectAtIndex:indexPath.row] objectAtIndex:1]];

            if([cell_name.txt_field1.text isEqualToString:@"<null>"]){

                cell_name.txt_field1.text = @"";
            }
            if([cell_name.txt_field2.text isEqualToString:@"<null>"]){

                cell_name.txt_field2.text = @"";
            }

            [cell_name.txt_field1 addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];
            [cell_name.txt_field2 addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_name;
        }

        //ふりがな
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"furigana1"]){

            cell_furigana = [tableView dequeueReusableCellWithIdentifier:@"first_furinaga_Identifier"];
            if(cell_furigana == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_furigana_TableViewCell" owner:self options:nil];
                cell_furigana = [nib objectAtIndex:0];
            }
            cell_furigana.txt_field1.delegate = self;
            cell_furigana.txt_field2.delegate = self;

            cell_furigana.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_furigana.fld_essential = YES;
            }else{

                cell_furigana.fld_essential = NO;
            }

            cell_furigana.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_furigana.fld_essential == YES){

                cell_furigana.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_furigana.lbl_name.text];
            }

            cell_furigana.txt_field1.text = [Utility checkNULL:[[memberObj.fld_value objectAtIndex:indexPath.row] objectAtIndex:0]];
            cell_furigana.txt_field2.text = [Utility checkNULL:[[memberObj.fld_value objectAtIndex:indexPath.row] objectAtIndex:1]];

            if([cell_furigana.txt_field1.text isEqualToString:@"<null>"]){

                cell_furigana.txt_field1.text = @"";
            }
            if([cell_furigana.txt_field2.text isEqualToString:@"<null>"]){

                cell_furigana.txt_field2.text = @"";
            }

            [cell_furigana.txt_field1 addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];
            [cell_furigana.txt_field2 addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_furigana;
        }

        //電話
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"tel"]){

            cell_tel = [tableView dequeueReusableCellWithIdentifier:@"first_tel_Identifier"];
            if(cell_tel == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_tel_TableViewCell" owner:self options:nil];
                cell_tel = [nib objectAtIndex:0];
            }
            cell_tel.txt_field.delegate = self;

            cell_tel.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_tel.fld_essential = YES;
            }else{

                cell_tel.fld_essential = NO;
            }

            cell_tel.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_tel.fld_essential == YES){

                cell_tel.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_tel.lbl_name.text];
            }

            cell_tel.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_tel.txt_field.text isEqualToString:@"<null>"]){

                cell_tel.txt_field.text = @"";
            }

            [cell_tel.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            //NumberPicker上部バー作成
            UIToolbar *numbaer_toolbar = [[UIToolbar alloc] init];
            numbaer_toolbar.backgroundColor = [UIColor whiteColor];
            numbaer_toolbar.frame=CGRectMake(0, 0, 320, 44);
            //DataPicker上部バーボタン設定
            UIBarButtonItem *numbaer_item0=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *numbaer_item1=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *numbaer_item2=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *numbaer_item3=[[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(telBtnClick)];
            numbaer_item3.tintColor = [UIColor blackColor];
            numbaer_toolbar.items=@[numbaer_item0,numbaer_item1,numbaer_item2,numbaer_item3];
            //DataPicker上部バー設定
            cell_tel.txt_field.inputAccessoryView = numbaer_toolbar;

            return cell_tel;
        }

        //年代
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"generation"]){

            cell_generation = [tableView dequeueReusableCellWithIdentifier:@"first_generation_Identifier"];
            if(cell_generation == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_generation_TableViewCell" owner:self options:nil];
                cell_generation = [nib objectAtIndex:0];
            }
            cell_generation.txt_field.delegate = self;

            cell_generation.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_generation.fld_essential = YES;
            }else{

                cell_generation.fld_essential = NO;
            }

            cell_generation.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_generation.fld_essential == YES){

                cell_generation.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_generation.lbl_name.text];
            }

            cell_generation.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_generation.txt_field.text isEqualToString:@"<null>"]){

                cell_generation.txt_field.text = @"";
            }

            [cell_generation.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_generation;
        }

        //利用店舗
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"shop"]){

            cell_shop = [tableView dequeueReusableCellWithIdentifier:@"first_shop_Identifier"];
            if(cell_shop == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_shop_TableViewCell" owner:self options:nil];
                cell_shop = [nib objectAtIndex:0];
            }
            cell_shop.txt_field.delegate = self;

            cell_shop.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_shop.fld_essential = YES;
            }else{

                cell_shop.fld_essential = NO;
            }

            cell_shop.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_shop.fld_essential == YES){

                cell_shop.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_shop.lbl_name.text];
            }

            cell_shop.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_shop.txt_field.text isEqualToString:@"<null>"]){

                cell_shop.txt_field.text = @"";
            }

            [cell_shop.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            return cell_shop;
        }

        //誕生日
        if([[memberObj.fld_name objectAtIndex:indexPath.row] isEqualToString:@"birthday"]){

            cell_birthday = [tableView dequeueReusableCellWithIdentifier:@"first_birthday_Identifier"];
            if(cell_birthday == nil){

                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TheFifth_birthday_TableViewCell" owner:self options:nil];
                cell_birthday = [nib objectAtIndex:0];
            }
            cell_birthday.txt_field.delegate = self;

            cell_birthday.IndexPathRow = indexPath.row;

            if([[memberObj.fld_essential objectAtIndex:indexPath.row] integerValue] == 1){

                cell_birthday.fld_essential = YES;
            }else{

                cell_birthday.fld_essential = NO;
            }

            cell_birthday.lbl_name.text = [Utility checkNULL:[memberObj.fld_colom objectAtIndex:indexPath.row]];

            if(cell_birthday.fld_essential == YES){

                cell_birthday.lbl_name.text = [NSString stringWithFormat:@"%@ *", cell_birthday.lbl_name.text];
            }

            cell_birthday.txt_field.text = [Utility checkNULL:[memberObj.fld_value objectAtIndex:indexPath.row]];

            if([cell_birthday.txt_field.text isEqualToString:@"<null>"]){

                cell_birthday.txt_field.text = @"";
            }

            [cell_birthday.txt_field addTarget:self action:@selector(getTextfield) forControlEvents:UIControlEventEditingDidEnd];

            //DataPicker 設定
            datePicker_Birthday = [[UIDatePicker alloc] init];
            datePicker_Birthday.datePickerMode=UIDatePickerModeDate;
            datePicker_Birthday.maximumDate = [NSDate date];
            datePicker_Birthday.backgroundColor = [UIColor whiteColor];
            datePicker_Birthday.locale=[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
            [datePicker_Birthday addTarget:self action:@selector(dateSet_Birthday:) forControlEvents:UIControlEventValueChanged];
            cell_birthday.txt_field.inputView = datePicker_Birthday;

            //DataPicker上部バー作成
            UIToolbar *toolbar = [[UIToolbar alloc] init];
            toolbar.backgroundColor = [UIColor whiteColor];
            toolbar.frame=CGRectMake(0, 0, 320, 44);
            //DataPicker上部バーボタン設定
            UIBarButtonItem *item0=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *item2=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *item3=[[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(previousBtnClick)];
            item3.tintColor = [UIColor blackColor];
            toolbar.items=@[item0,item1,item2,item3];
            //DataPicker上部バー設定
            cell_birthday.txt_field.inputAccessoryView = toolbar;

            return cell_birthday;
        }
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(void)dateSet_Birthday:(UIDatePicker *)picker {

    NSDate *selectDate=picker.date;
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yyy-MM-dd";
    NSString *stringDate=[formatter stringFromDate:selectDate];

    cell_birthday.txt_field.text = stringDate;
}

-(void)previousBtnClick {

    [cell_birthday.txt_field resignFirstResponder];
}
-(void)zipcodeBtnClick {

    [cell_zipcode.txt_field resignFirstResponder];
}
-(void)telBtnClick {

    [cell_tel.txt_field resignFirstResponder];
}

- (void)getTextfield {

    //会員情報保存項目取得
    NSMutableArray* ary_field = [[NSMutableArray alloc] init];
    for(long l=0;l<memberObj.fld_value.count;l++){

        if([[memberObj.fld_name objectAtIndex:l] isEqualToString:@"name1"]){

            NSMutableArray* ary1 = [[NSMutableArray alloc] init];
            [ary1 addObject:@"name1"];
            [ary1 addObject:[[memberObj.fld_value objectAtIndex:l] objectAtIndex:0]];

            [ary_field addObject:ary1];

            NSMutableArray* ary2 = [[NSMutableArray alloc] init];
            [ary2 addObject:@"name2"];
            [ary2 addObject:[[memberObj.fld_value objectAtIndex:l] objectAtIndex:1]];

            [ary_field addObject:ary2];
        }else
        if([[memberObj.fld_name objectAtIndex:l] isEqualToString:@"furigana1"]){

            NSMutableArray* ary1 = [[NSMutableArray alloc] init];
            [ary1 addObject:@"furigana1"];
            [ary1 addObject:[[memberObj.fld_value objectAtIndex:l] objectAtIndex:0]];

            [ary_field addObject:ary1];

            NSMutableArray* ary2 = [[NSMutableArray alloc] init];
            [ary2 addObject:@"furigana2"];
            [ary2 addObject:[[memberObj.fld_value objectAtIndex:l] objectAtIndex:1]];

            [ary_field addObject:ary2];
        }else{

            NSMutableArray* ary = [[NSMutableArray alloc] init];
            [ary addObject:[memberObj.fld_name objectAtIndex:l]];
            [ary addObject:[memberObj.fld_value objectAtIndex:l]];

            [ary_field addObject:ary];
        }
    }

//    [[ManagerDownload sharedInstance] setMemberInfo:[Utility getAppID] withDeviceID:[Utility getDeviceID] withShrareCode:@"" withfield:ary_field delegate:self];
}

- (void)backButtonClicked:(UIButton *)sender {

}

#pragma mark - ManagerDownloadDelegate
- (void)downloadDataSuccess:(DownloadParam *)param {

    switch (param.request_type) {
        case RequestType_GET_MEMBER_INFO:
        {
            if(param.listData.count > 0){

                memberObj = param.listData[0];

                [_tbl_userSetting reloadData];

                [self resizeTable];
            }
        }
            break;

        default:
            break;
    }
}

- (void)resizeTable {

    //コレクション高さをセルの最大値へセット
    _tbl_userSetting.translatesAutoresizingMaskIntoConstraints = YES;
    _tbl_userSetting.frame = CGRectMake(_tbl_userSetting.frame.origin.x, _tbl_userSetting.frame.origin.y, _tbl_userSetting.frame.size.width, 0);
    _tbl_userSetting.frame =
    CGRectMake(_tbl_userSetting.frame.origin.x,
               _tbl_userSetting.frame.origin.y,
               _tbl_userSetting.contentSize.width,
               MAX(_tbl_userSetting.contentSize.height,
                   _tbl_userSetting.bounds.size.height));
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    NSLog(@"height : %f", rect_screen.size.height);

    if(textField == cell_nick_name.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_nick_name.IndexPathRow * 40;
    }

    if(textField == cell_gender.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_gender.IndexPathRow * 40;
    }

    if(textField == cell_mail.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_mail.IndexPathRow * 40;
    }

    if(textField == cell_job.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_job.IndexPathRow * 40;
    }

    if(textField == cell_zipcode.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_zipcode.IndexPathRow * 40;
    }

    if(textField == cell_address.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_address.IndexPathRow * 40;
    }

    if(textField == cell_name.txt_field1){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_name.IndexPathRow * 40;
    }

    if(textField == cell_name.txt_field2){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_name.IndexPathRow * 40;
    }

    if(textField == cell_furigana.txt_field1){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_furigana.IndexPathRow * 40;
    }

    if(textField == cell_furigana.txt_field2){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_furigana.IndexPathRow * 40;
    }

    if(textField == cell_tel.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_tel.IndexPathRow * 40 + 20;
    }

    if(textField == cell_generation.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_generation.IndexPathRow * 40;
    }


    if(textField == cell_shop.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_shop.IndexPathRow * 40 + 20;
    }

    if(textField == cell_birthday.txt_field){

        cgpoint_tf.x = 0.0f;
        cgpoint_tf.y = 192 + cell_birthday.IndexPathRow * 40;
    }

    kb_type = textField.keyboardType;
    
    return YES;
}

- (void)showKeyboard:(NSNotification*)notification {

    // ステータスバーをのぞいた画面高さ
    float afh = [[UIScreen mainScreen] bounds].size.height - 20;

    // キーボード高さ
    CGRect keyboard;
    keyboard = [[notification.userInfo
                 objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float kbh = keyboard.size.height;

    CGPoint cgpoint_reset = cgpoint_tf;

    float flt_SetScreenSize = (afh - 44 - 33 - kbh);
    float flt_SetScroolPoint = 8 + cgpoint_tf.y + 60;

    if(flt_SetScroolPoint < flt_SetScreenSize){

        cgpoint_reset.y = 0;
    }else{

        cgpoint_reset.y = flt_SetScroolPoint - flt_SetScreenSize + 7;
    }

    [_scr_rootview setContentOffset:cgpoint_reset animated:YES];
}

- (void)enterButton:(UIButton*)sender {

    //キーボードクローズ
    [cell_nick_name.txt_field resignFirstResponder];
    [cell_gender.txt_field resignFirstResponder];
    [cell_mail.txt_field resignFirstResponder];
    [cell_job.txt_field resignFirstResponder];
    [cell_zipcode.txt_field resignFirstResponder];
    [cell_address.txt_field resignFirstResponder];
    [cell_name.txt_field1 resignFirstResponder];
    [cell_name.txt_field2 resignFirstResponder];
    [cell_furigana.txt_field1 resignFirstResponder];
    [cell_furigana.txt_field2 resignFirstResponder];
    [cell_tel.txt_field resignFirstResponder];
    [cell_generation.txt_field resignFirstResponder];
    [cell_shop.txt_field resignFirstResponder];
    [cell_birthday.txt_field resignFirstResponder];
}

- (void)hideKeyboard:(NSNotification*)notification {

    //キーボードクローズ
    [cell_nick_name.txt_field resignFirstResponder];
    [cell_gender.txt_field resignFirstResponder];
    [cell_mail.txt_field resignFirstResponder];
    [cell_job.txt_field resignFirstResponder];
    [cell_zipcode.txt_field resignFirstResponder];
    [cell_address.txt_field resignFirstResponder];
    [cell_name.txt_field1 resignFirstResponder];
    [cell_name.txt_field2 resignFirstResponder];
    [cell_furigana.txt_field1 resignFirstResponder];
    [cell_furigana.txt_field2 resignFirstResponder];
    [cell_tel.txt_field resignFirstResponder];
    [cell_generation.txt_field resignFirstResponder];
    [cell_shop.txt_field resignFirstResponder];
    [cell_birthday.txt_field resignFirstResponder];
}

//カスタムナビゲーション押した時にキーボード閉じる為のメソッド
- (void)hideKeyboard {

    //キーボードクローズ
    [cell_nick_name.txt_field resignFirstResponder];
    [cell_gender.txt_field resignFirstResponder];
    [cell_mail.txt_field resignFirstResponder];
    [cell_job.txt_field resignFirstResponder];
    [cell_zipcode.txt_field resignFirstResponder];
    [cell_address.txt_field resignFirstResponder];
    [cell_name.txt_field1 resignFirstResponder];
    [cell_name.txt_field2 resignFirstResponder];
    [cell_furigana.txt_field1 resignFirstResponder];
    [cell_furigana.txt_field2 resignFirstResponder];
    [cell_tel.txt_field resignFirstResponder];
    [cell_generation.txt_field resignFirstResponder];
    [cell_shop.txt_field resignFirstResponder];
    [cell_birthday.txt_field resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //space remove
    if (![string compare:@" "]) {
        return NO;
    }

    // 変更前のtextを取得
    NSMutableString *tmp =[textField.text mutableCopy];
    // 編集後のtext
    [tmp replaceCharactersInRange:range withString:string];
    /*
     //ニックネーム入力規制
     if(textField == self.txt_nickName){

     return [tmp lengthOfBytesUsingEncoding:NSShiftJISStringEncoding] <= 20;
     }

     //郵便番号入力規制
     if(textField == self.txt_zipCode){

     if(![self containsOnlyDecimalNumbers1:tmp]){

     return NO;
     }

     return [tmp lengthOfBytesUsingEncoding:NSShiftJISStringEncoding] <= 7;
     }
     */
    return YES;
}

- (BOOL)containsOnlyDecimalNumbers1:(NSString *)string
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    return [[NSCharacterSet decimalDigitCharacterSet] isSupersetOfSet:characterSet];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

     if(textField == cell_nick_name.txt_field){

         // 受け取った入力をラベルに代入
         cell_gender.txt_field.text = textField.text;
     }

     if(textField == cell_gender.txt_field){

         // 受け取った入力をラベルに代入
         cell_gender.txt_field.text = textField.text;
     }

     if(textField == cell_mail.txt_field){

         // 受け取った入力をラベルに代入
         cell_mail.txt_field.text = textField.text;
     }

     if(textField == cell_job.txt_field){

         // 受け取った入力をラベルに代入
         cell_job.txt_field.text = textField.text;
     }

     if(textField == cell_zipcode.txt_field){

         // 受け取った入力をラベルに代入
         cell_zipcode.txt_field.text = textField.text;
     }

     if(textField == cell_address.txt_field){

         // 受け取った入力をラベルに代入
         cell_address.txt_field.text = textField.text;
     }

     if(textField == cell_name.txt_field1){

         // 受け取った入力をラベルに代入
         cell_name.txt_field1.text = textField.text;
     }

    if(textField == cell_name.txt_field2){

        // 受け取った入力をラベルに代入
        cell_name.txt_field2.text = textField.text;
    }

    if(textField == cell_furigana.txt_field1){

        // 受け取った入力をラベルに代入
        cell_furigana.txt_field1.text = textField.text;
    }

    if(textField == cell_furigana.txt_field2){

        // 受け取った入力をラベルに代入
        cell_furigana.txt_field2.text = textField.text;
    }

    if(textField == cell_generation.txt_field){

        // 受け取った入力をラベルに代入
        cell_generation.txt_field.text = textField.text;
    }

    if(textField == cell_shop.txt_field){

        // 受け取った入力をラベルに代入
        cell_shop.txt_field.text = textField.text;
    }

    if(textField == cell_birthday.txt_field){

        // 受け取った入力をラベルに代入
        cell_birthday.txt_field.text = textField.text;
    }

    // キーボードを閉じる
    [textField resignFirstResponder];

    return YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    //キーボードクローズ
    [cell_nick_name.txt_field resignFirstResponder];
    [cell_gender.txt_field resignFirstResponder];
    [cell_mail.txt_field resignFirstResponder];
    [cell_job.txt_field resignFirstResponder];
    [cell_zipcode.txt_field resignFirstResponder];
    [cell_address.txt_field resignFirstResponder];
    [cell_name.txt_field1 resignFirstResponder];
    [cell_name.txt_field2 resignFirstResponder];
    [cell_furigana.txt_field1 resignFirstResponder];
    [cell_furigana.txt_field2 resignFirstResponder];
    [cell_tel.txt_field resignFirstResponder];
    [cell_generation.txt_field resignFirstResponder];
    [cell_shop.txt_field resignFirstResponder];
    [cell_birthday.txt_field resignFirstResponder];
}

- (void)downloadDataFail:(DownloadParam *)param {
}

- (IBAction)sw_newsNotification:(id)sender {
}

- (IBAction)sw_recommended:(id)sender {
}

- (IBAction)sw_recommendedMenu:(id)sender {
}

- (IBAction)sw_catalog:(id)sender {
}

- (IBAction)sw_curpon:(id)sender {
}

- (IBAction)btn_transfer:(id)sender {

    MPTransferViewController *vc = [[MPTransferViewController alloc] initWithNibName:@"MPTransferViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btn_teams:(id)sender {

    MPTermsViewController *vc = [[MPTermsViewController alloc] initWithNibName:@"MPTermsViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btn_porisir:(id)sender {
}

@end

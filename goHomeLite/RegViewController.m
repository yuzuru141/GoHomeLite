//
//  RegViewController.m
//  goHomeLite
//
//  Created by 石井嗣 on 2014/12/17.
//  Copyright (c) 2014年 YuZ. All rights reserved.
//

#import "RegViewController.h"

@interface RegViewController ()

@end

@implementation RegViewController{
    UISwitch *sw;
    BOOL locationSearch;
//    BOOL firstlocation;
    NSArray* aItemList;
    NSArray* aItemList2;
    NSInteger selectTimeFrom;
    NSInteger selectTimeTo;
    NSString *addressStr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self viewBackground];
    
    //バックグラウンド通信ができるか確認する
    [self backgroundCheck];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    //メモリーリーク防止の為に、一旦ジオフェンスを停止
    [self geoFenceCancel];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(fire)
//                                                 name:@"UIApplicationDidReceiveLocalNotification"
//                                               object:nil];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewBackground{
    
    //現在地を設定するか検索で場所を指定するかで使うlocationSearchを初期化しておく
//    locationSearch = nil;
    
    //位置情報をスタートする日付も初期化しておく
    selectTimeFrom = 0;
    selectTimeTo = 0;
    
    //位置情報を取得するのが最初かどうかフラグを立てる
//    BOOL firstlocation = YES;
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;

//    scrollview = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
//    scrollview.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
//    [self.view addSubview:scrollview];
    
    NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    
    //宛先メールラベル
    CGRect mailLabelRect = CGRectMake(width/10, height/9, width-width/10*2, 35);
    UILabel *mailLabel = [[UILabel alloc]initWithFrame:mailLabelRect];
    mailLabel.text = @"宛先メール";
    [self.view addSubview:mailLabel];
    
    //宛先メールtextfield
    CGRect mailTextRect = CGRectMake(width/10+40, height/9+30, width-width/10*2, 35);
    UITextField *mailTextfield = [[UITextField alloc]initWithFrame:mailTextRect];
    NSString *mailString = [myDefault objectForKey:@"toMAIL"];
    if (mailString == nil || [ mailString isEqualToString:@""]) {
        mailTextfield.placeholder = @"***@mail.com";
    }else{
        mailTextfield.text = mailString;
    }
    //    textfield.layer.cornerRadius =3;
    mailTextfield.tag = 0;
    mailTextfield.returnKeyType = UIReturnKeyDefault;
    mailTextfield.keyboardType = UIKeyboardTypeEmailAddress;
    mailTextfield.delegate = self;
    [self.view addSubview:mailTextfield];
    
    
    //送信文言textfield
    CGRect subjectTextRect = CGRectMake(width/10+40, height/9*2, width-width/10*2, 35);
    UITextField *subjectTextfield = [[UITextField alloc]initWithFrame:subjectTextRect];
    NSString *subjcetString = [myDefault objectForKey:@"SUBJECT"];
    if (subjcetString == nil || [ subjcetString isEqualToString:@""]) {
        subjectTextfield.placeholder = @"帰ります";
    }else{
        subjectTextfield.text = subjcetString;
    }

    //    textfield.layer.cornerRadius =3;
    subjectTextfield.tag = 2;
    subjectTextfield.returnKeyType = UIReturnKeyDefault;
    subjectTextfield.keyboardType = UIKeyboardTypeDefault;
    subjectTextfield.delegate = self;
    [self.view addSubview:subjectTextfield];
    
    //この場所を登録しますかラベル
    CGRect thisPlaceRect = CGRectMake(width/10, height/9*3, width-width/10*2, 35);
    UILabel *labelPlan = [[UILabel alloc]initWithFrame:thisPlaceRect];
    labelPlan.text = NSLocalizedString(@"register this place", nil);
    [self.view addSubview:labelPlan];
    
    //登録スイッチ
    CGRect swRect = CGRectMake(width/10*2, height/9*3+30, width-width/4, 35);
    sw= [[UISwitch alloc] initWithFrame:swRect];
    sw.onTintColor = [UIColor blackColor];
    sw.on = NO;
    [sw addTarget:self action:@selector(placeSetHere:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sw];
    
    //検索サイトへ飛ぶボタン
    CGRect buttonSearchRect = CGRectMake(width/10, height/9*4, width-width/10*2, 35);
    UIButton *search = [[UIButton alloc]initWithFrame:buttonSearchRect];
    search.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [search setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [search setTitle:@"search place name" forState:UIControlStateNormal];
    [search addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:search];
    
    //検索後のターゲット名前を表示させるラベル
    CGRect targetName = CGRectMake(width/10+40, height/9*4+30, width-width/10*2, 35);
    UILabel *labelName = [[UILabel alloc]initWithFrame:targetName];
    NSString *placeName = [[NSString alloc]init];
    placeName = [myDefault objectForKey:@"PLACE"];
//    if(!(placeName==nil)){
//        [myDefault setObject:nil forKey:@"PLACE"];
//    }else{
//        
//    }
    labelName.text = placeName;
    [self.view addSubview:labelName];

    //半径指定ラベル
    CGRect radiusLabelRect = CGRectMake(width/10, height/9*5, width-width/10*2, 35);
    UILabel *radiusLabel = [[UILabel alloc]initWithFrame:radiusLabelRect];
    radiusLabel.text = NSLocalizedString(@"please set radius", nil);
    [self.view addSubview:radiusLabel];
    
    //メートルラベル
    CGRect meterLabelRect = CGRectMake(width/10+100, height/9*5+30, 35, 35);
    UILabel *meterLabel = [[UILabel alloc]initWithFrame:meterLabelRect];
    meterLabel.text = @"M";
    [self.view addSubview:meterLabel];
    
    //半径指定textfield
    CGRect radiusTextRect = CGRectMake(width/10+40, height/9*5+30, width-width/10*2, 35);
    UITextField *textfield = [[UITextField alloc]initWithFrame:radiusTextRect];
    textfield.placeholder = @"500";
    textfield.tag = 1;
//    textfield.layer.cornerRadius =3;
    textfield.returnKeyType = UIReturnKeyDefault;
    textfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    textfield.delegate = self;
    [self.view addSubview:textfield];
    
    //帰宅時間ラベル
    CGRect timeLabelRect = CGRectMake(width/10, height/9*6, width-width/10*2, 35);
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:timeLabelRect];
    timeLabel.text = @"帰宅時間";
    [self.view addSubview:timeLabel];
    
    //帰宅時間ピッカー
    aItemList = [[NSArray alloc] initWithObjects:@"00:00",@"01:00",@"02:00",@"03:00",@"04:00",@"05:00",@"06:00",@"07:00",@"08:00",@"09:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00",nil];
    aItemList2 = [[NSArray alloc] initWithObjects:@"01:00",@"02:00",@"03:00",@"04:00",@"05:00",@"06:00",@"07:00",@"08:00",@"09:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00",@"24:00",nil];
    UIPickerView*  oPicker = [[UIPickerView alloc] init];
    oPicker.frame = CGRectMake(width/10+40, height/9*6+15, width-width/10*2, 35);
    oPicker.showsSelectionIndicator = YES;
    oPicker.delegate = self;
    oPicker.dataSource = self;
//    oPicker.tag = 1;
    CGAffineTransform t0 = CGAffineTransformMakeTranslation(oPicker.bounds.size.width/2, oPicker.bounds.size.height/2);
    CGAffineTransform s0 = CGAffineTransformMakeScale(0.7, 0.7);
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(-oPicker.bounds.size.width/2, -oPicker.bounds.size.height/2);
    oPicker.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1));
    

    NSInteger timeFirstInt = [myDefault integerForKey:@"SELECTTIMEFIRST"];
    NSInteger timeEndInt = [myDefault integerForKey:@"SELECTTIMEEND"]-1;
    
    //NSuserdefaultsから取得した情報をpickerの初期値に反映。
    if (!(timeFirstInt == 0)) {
        [oPicker selectRow:timeFirstInt inComponent:0 animated:YES];
        NSLog(@"timeFirstInt=%ld",(long)timeFirstInt);
    }
    if (!(timeEndInt == 0)) {
        [oPicker selectRow:timeEndInt inComponent:1 animated:YES];
        NSLog(@"timeEndInt=%ld",(long)timeEndInt);
    }
    
    [self.view addSubview:oPicker];
    
    //設定完了ボタン
    CGRect buttonDoneRect = CGRectMake(0, height/9*8, width, 35);
    UIButton *done = [[UIButton alloc]initWithFrame:buttonDoneRect];
    done.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [done setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    [done addTarget:self action:@selector(doneButton) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:done];
    
}

//現時点で登録するスイッチ
- (IBAction)placeSetHere:(UISwitch*)sender{
    
    if(sw.on==1){
        //登録情報をクリアにする
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        if(!([myDefault objectForKey:@"PLACE"]==nil)){
            [myDefault setObject:nil forKey:@"PLACE"];
        }
        
        //位置情報とジオフェンスセット開始
        [self locationAuth];
        locationSearch = NO;
    }else{
        locationSearch = YES;
    }
    NSLog(@"locationSearch=%d",locationSearch);
}


//textfieldでリターンキーが押されるとキーボードを隠す。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    if (textField.tag == 0) {
        //全角チェック
        if(![textField.text canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            [self alertViewMethod:@"半角英数字とアルファベットで入力してください"];
        }else{
            //@が含まれているかチェック
            NSRange range = [textField.text rangeOfString:@"@"];
            if (range.location != NSNotFound) {
                if ([textField.text rangeOfString:@" "].location != NSNotFound) {
                    //空文字チェック
                    [self alertViewMethod:@"メールアドレスにスペースが入っていますので、確認してください"];
                }else{
                NSLog(@"@発見");
                [mydefault setObject:textField.text forKey:@"toMAIL"];
                NSLog(@"Mail=%@",textField.text);
                }
            } else {
                NSLog(@"@ない");
                [self alertViewMethod:@"適切なメールアドレスを入力してください"];
            }
        }
    }else if(textField.tag == 1){
        [mydefault setObject:textField.text forKey:@"RADIUS"];
        NSLog(@"RADIUS=%@",textField.text);
    }else if(textField.tag == 2){
        if (textField.text == nil || [ textField.text isEqualToString:@""]) {
            [mydefault setObject:@"帰ります" forKey:@"SUBJECT"];
            NSLog(@"SUBJECT=帰ります");
        }else{
            [mydefault setObject:textField.text forKey:@"SUBJECT"];
            NSLog(@"SUBJECT=%@",textField.text);
        }
    }
    [mydefault synchronize];
    [textField resignFirstResponder];
    return YES;
}


//区切りの数（コンポーネント）
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
        return 2;
}


//ピッカーの項目数を選択
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
        return [aItemList count];
}


//picker選択行を抽出
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSUserDefaults *selectTimeDefault = [NSUserDefaults standardUserDefaults];
    
    switch (component) {
        case 0: // 1列目
            selectTimeFrom = 0;
            selectTimeFrom = [pickerView selectedRowInComponent:0];
            NSLog(@"%ldから",(long)selectTimeFrom);
            [selectTimeDefault setInteger:selectTimeFrom forKey:@"SELECTTIMEFIRST"];
            [selectTimeDefault synchronize];
            return;
            break;
        case 1: // 2列目
            selectTimeTo = 0;
            selectTimeTo = 1+[pickerView selectedRowInComponent:1];
            NSLog(@"%ldまで",(long)selectTimeTo);
            [selectTimeDefault setInteger:selectTimeTo forKey:@"SELECTTIMEEND"];
            [selectTimeDefault synchronize];
            return;
            break;
        default:
            return;
            break;
        }
}


//ピッカーの文字を変更する
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:18];
    }else{
        label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:35];
    }
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    switch (component) {
        case 0: // 1列目
            label.text = [NSString stringWithFormat:@"%@から", [aItemList objectAtIndex:row]];
            return label;
            break;
        case 1: // 2列目
            label.text = [NSString stringWithFormat:@"%@", [aItemList2 objectAtIndex:row]];
            return label;
            break;
        default:
            return 0;
            break;

    }
}


//ピッカーの幅の調整
- (CGFloat)pickerView:(UIPickerView *)pickerView
    widthForComponent:(NSInteger)component
{
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    return width-width/10*5;
}


//ピッカーの高さを設定する
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}



//「Appのバックグラウンド更新」の設定値を取得
- (void)backgroundCheck{
    UIBackgroundRefreshStatus status = [UIApplication sharedApplication].backgroundRefreshStatus;
    
    //判定処理
    switch (status) {
        case UIBackgroundRefreshStatusAvailable:
            //Appの自動更新がON
            NSLog(@"%@",@"利用できる");
            break;
        case UIBackgroundRefreshStatusDenied:
            //Appの自動更新がOFF もしくは、ONだがこのアプリはOFF
            NSLog(@"%@",@"拒否された");
            [self alertViewMethod:@"バックグラウンド動作を設定の一般のAppのバックグラウンド更新から許可してください。"];
            break;
        case UIBackgroundRefreshStatusRestricted:
            //ペアレンタルコントロール時に入るかも
            NSLog(@"%@",@"制限");
            [self alertViewMethod:@"バックグラウンド動作を設定の一般のAppのバックグラウンド更新から許可してください。"];
            break;
        default:
            //どんなケースで入るのか不明
            NSLog(@"%@",@"どれでもない");
            [self alertViewMethod:@"バックグラウンド動作を設定の一般のAppのバックグラウンド更新から許可してください。"];
            break;
    }
}


//位置情報機能がONにされているかiosのバージョンで確認する
- (void)locationAuth{

        //iOS8であれば確認メッセージを入れる
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // iOS バージョンが 8 以上で、requestAlwaysAuthorization メソッドが利用できる場合、位置情報測位の許可を求めるメッセージを表示する
            [self.locationManager requestAlwaysAuthorization];
            NSLog(@"iOS8");
        } else {
            // iOS バージョンが 8 未満の場合は、測位を開始する
            [self.locationManager startUpdatingLocation];
            NSLog(@"iOS7以下");
            }
}

//iOS8の場合はステータスが変わるので、それに基づいて位置情報通信を始める
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    status = [CLLocationManager authorizationStatus];
    switch (status) {
            
        case kCLAuthorizationStatusAuthorizedAlways: // 位置情報サービスへのアクセスが常に許可されている
            NSLog(@"アクセスが常に許可されている");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:// 位置情報サービスへのアクセスがアプリ使用中に許可されている
            NSLog(@"アクセスがアプリ使用中に許可されている");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusNotDetermined: // 位置情報サービスへのアクセスを許可するか選択されていない
            NSLog(@"アクセスを許可するか選択されていない");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusRestricted: // 設定 > 一般 > 機能制限で利用が制限されている
            NSLog(@"設定 > 一般 > 機能制限で利用が制限されている");
            [self alertViewMethod:@"設定 > 一般 > 機能制限から利用を許可してください。"];
            break;
            
        case kCLAuthorizationStatusDenied: // ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
            NSLog(@"ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない");
            [self alertViewMethod:@"設定 > プライバシー > 位置情報サービスから利用を許可してください。"];
            break;
            
        default:
            NSLog(@"default");
            if ([CLLocationManager locationServicesEnabled]) {
                
                // 測位開始
                [self.locationManager startUpdatingLocation];
            }
            
            break;
    }

}


//現在地を一回取得する
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
//    if (firstlocation == YES && locationSearch == NO) {
//        //現在地をジオフェンスにセットするため、緯度経度を取得する
//        NSUserDefaults *thisPlace = [NSUserDefaults standardUserDefaults];
//        [thisPlace setDouble:newLocation.coordinate.longitude forKey:@"LONHERE"];
//        [thisPlace setDouble:newLocation.coordinate.latitude forKey:@"LATHERE"];
//        [thisPlace synchronize];
//    }
//    firstlocation = NO;
    
    if (locationSearch == NO) {
        //現在地をジオフェンスにセットするため、緯度経度を取得する
        NSUserDefaults *thisPlace = [NSUserDefaults standardUserDefaults];
        [thisPlace setDouble:newLocation.coordinate.longitude forKey:@"LONHERE"];
        [thisPlace setDouble:newLocation.coordinate.latitude forKey:@"LATHERE"];
        [thisPlace synchronize];
    }
    
    [self.locationManager stopUpdatingLocation];
}


// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる関数
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}


//完了ボタンでジオフェンスをセットする
- (void)doneButton{
    
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSString *radiusString = [mydefault objectForKey:@"RADIUS"];
    
    CLLocationDistance radiusOnMeter = radiusString.doubleValue;
    if (radiusOnMeter == 0.00) {
        radiusOnMeter = 500.00;
    }
    
    NSLog(@"radius=%f",radiusOnMeter);
    
    double lat;
    double lon;
    
    if (locationSearch==YES) {
        lat = [mydefault doubleForKey:@"LAT"];
        lon = [mydefault doubleForKey:@"LON"];
    }else{
        lat = [mydefault doubleForKey:@"LATHERE"];
        lon = [mydefault doubleForKey:@"LONHERE"];
    }
    
    NSLog(@"lat=%f",lat);
    NSLog(@"lon=%f",lon);
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(lat, lon)
                                                                 radius:radiusOnMeter
                                                             identifier:@"target"];
    
//    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(37.785834, -122.406417)
//                                                                 radius:200
//                                                             identifier:@"target"];
    
    NSLog(@"region=%@",[region description]);
    //ジオフェンスをスタート
    [self.locationManager startMonitoringForRegion:region];
    
    //開始時間と終了時間が同じであればすぐにロケーションマネージャを立ち上げる
    if ((selectTimeFrom==selectTimeTo)&&(selectTimeFrom!=0 && selectTimeTo!=0)) {
        NSInteger timeFirstInt = [mydefault integerForKey:@"SELECTTIMEFIRST"];
        NSInteger timeEndInt = [mydefault integerForKey:@"SELECTTIMEEND"]-1;
        //NSuserdefaultsから取得した情報をpickerの初期値に反映。
        if ((timeFirstInt == 0) || (timeEndInt == 0)) {
            [self alertViewMethod:@"帰宅時間の範囲が正しく設定されていません"];
        }
    }
    //開始時間の方が終了時間よりも大きかったらすぐにロケーションマネージャを立ち上げる
    else if (selectTimeFrom>selectTimeTo){
        NSInteger timeFirstInt = [mydefault integerForKey:@"SELECTTIMEFIRST"];
        NSInteger timeEndInt = [mydefault integerForKey:@"SELECTTIMEEND"]-1;
        //NSuserdefaultsから取得した情報をpickerの初期値に反映。
        if ((timeFirstInt == 0) || (timeEndInt == 0)) {
            [self alertViewMethod:@"帰宅時間の範囲が正しく設定されていません"];
        }
    }//時間を設定しない状態だと警告を流す
    else if (selectTimeFrom==0 && selectTimeTo==0){
        //すでに選択している時はエラーを出さない
        NSInteger timeFirstInt = [mydefault integerForKey:@"SELECTTIMEFIRST"];
        NSInteger timeEndInt = [mydefault integerForKey:@"SELECTTIMEEND"]-1;
        //NSuserdefaultsから取得した情報をpickerの初期値に反映。
        if ((timeFirstInt == 0) || (timeEndInt == 0)) {
            [self alertViewMethod:@"帰宅時間を設定してください"];
        }
    }

    NSDate *today = [NSDate date];
    NSCalendar *currentCalendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    dateComp = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth
                                                    | NSCalendarUnitDay  | NSCalendarUnitHour
                                                    | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                          fromDate:today];
    NSLog(@"dateComp=%ld",(long)dateComp.minute);
    NSInteger needMinutes = 60-(long)dateComp.minute;
    
    NSUserDefaults *selectTimeDefault = [NSUserDefaults standardUserDefaults];
    selectTimeFrom = [selectTimeDefault integerForKey:@"SELECTTIMEFIRST"];
    NSLog(@"selectTimeFrom=%ld",selectTimeFrom);
    selectTimeTo = [selectTimeDefault integerForKey:@"SELECTTIMEEND"];
    NSLog(@"selectTimeTo=%ld",selectTimeTo);

    //現在すでにユーザが設定した時間であればすぐにfire
    if (selectTimeFrom <= (long)dateComp.hour){
            if((long)dateComp.hour < selectTimeTo){
//        [self fire];
        [self runLoop];
//                NSLog(@"すでにジオフェンス開始時間内です");
            }
    }
    //ユーザが選択した時間かどうか１時間に一回チェックする
    [self performSelector:@selector(runLoopMethod) withObject:nil afterDelay:needMinutes];
    //NSLog(@"%ld分後にチェックします",(long)needMinutes);
    
    
    //現在地を取得した場合は、現在地の住所を返す
    NSString *placeName = [mydefault objectForKey:@"PLACE"];
    if (placeName == nil || [ placeName isEqualToString:@""]){
        NSString *placeAdress= [self getAddressFromLat:lat AndLot:lon];
        NSLog(@"placeAdress=%@",placeAdress);
        [mydefault setObject:placeAdress forKey:@"PLACE"];
        NSLog(@"サーチしてない");
    }
    

    [mydefault synchronize];
    
    //最初のViewControllerに戻る
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"regviewToView" sender:self];
    
    
    
}


//緯度経度から住所を取得する
-(NSString *)getAddressFromLat:(double)lat AndLot:(double)lot{
    NSDictionary *jsonObjectResults = nil;
    NSString *urlApi1 = @"http://maps.google.com/maps/api/geocode/json?latlng=";
    NSString *urlApi2 = @"&sensor=false";
    NSString *urlApi = [NSString stringWithFormat:@"%@%f,%f%@",urlApi1,lat,lot,urlApi2];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlApi]cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //sendSynchronousRequestメソッドでURLにアクセス
    NSHTTPURLResponse* resp;
    NSData *json_data = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
    
    //通信エラーの際の処理
    if (resp.statusCode != 200){
        [self alertViewMethod:@"network error"];//アラートビュー出す
    }
    
    //返ってきたデータをJSONObjectWithDataメソッドで解析
    else{
        jsonObjectResults = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingAllowFragments error:nil];
        
        NSDictionary *status = [jsonObjectResults objectForKey:@"status"];
        NSString *statusString = [status description];
        
        if ([statusString isEqualToString:@"ZERO_RESULTS"]) {
            //            [self alertViewMethod]; //アラートビュー出す
            NSLog(@"ZERO_RESULTS");
            addressStr = @" ";
        }else if([statusString isEqualToString:@"OVER_QUERY_LIMIT"]){
            NSLog(@"OVER_QUERY_LIMIT");
            addressStr = @" ";
        }else{
            NSMutableArray *result = [jsonObjectResults objectForKey:@"results"];
            NSDictionary *dic = [result objectAtIndex:0];
            NSDictionary *dic2 = [dic objectForKey:@"formatted_address"];
            NSString *fullAddress = [dic2 description];
            addressStr = [fullAddress substringFromIndex:3];
        }
    }
    NSString *temp = addressStr;
    return temp;
}



//timerで呼び出す緯度経度情報
- (void)getGpsData:(NSTimer *)theTimer {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];// 座標を取得
    NSString *lat = [[NSString alloc] initWithFormat:@"%f", coordinate.latitude];  // 経度を取得
    NSString *lng = [[NSString alloc] initWithFormat:@"%f", coordinate.longitude]; // 緯度を取得
    NSLog(@"現在地緯度,经度: %@, %@", lat, lng);
}


// 進入イベント 通知
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"ジオフェンス領域に入りました");
}


//退出イベント　通知
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region{
    NSLog(@"ジオフェンス領域から出ました");
    
    
//    // LINEで送る（Lineアプリの起動なのであまり意味がない。。）
//    UIImage *image = [UIImage imageNamed:@"kaeru.png"];
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    [pasteboard setData:UIImagePNGRepresentation(image)
//      forPasteboardType:@"public.png"];
//    NSString *lineUrlString = [NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lineUrlString]];
    
    
    //gmail送信
    [self sendEmailInBackground];
    
    //ショートメール送信をしようとしたがアプリを立ち上げるので、止める
//    [self displaySMSComposerSheet];
    NSLog(@"発信!");
}


//SMS送信
//- (void)displaySMSComposerSheet {
//    // シミュレータでは SMS が起動しないので return する。
//    if(![MFMessageComposeViewController canSendText]) {
//        return;
//    }
//    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
//    picker.messageComposeDelegate = self;
//    picker.body = [NSString stringWithUTF8String:"もうすぐ帰ります"];
//    picker.recipients = [NSArray arrayWithObjects:@"080-3926-1414", nil];
//    NSLog(@"SNS発信");
//    [self presentModalViewController:picker animated:YES];
//}
//
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//    [self dismissModalViewControllerAnimated:YES];
//}

//gMailを送信
-(void)sendEmailInBackground
{
    //情報呼び出し
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    NSString *toMailAdress = [mydefault stringForKey:@"toMAIL"];
    NSString *subjectString = [mydefault stringForKey:@"SUBJECT"];
    NSString *gmailAddress = [mydefault stringForKey:@"GMAIL"];
    if (gmailAddress == nil || [ gmailAddress isEqualToString:@""]) {
        [self alertViewMethod:@"自分のgmail情報がありません"];
        return;
    }
    NSString *pwString = [mydefault stringForKey:@"PASSWORD"];
    if (pwString == nil || [ pwString isEqualToString:@""]){
        [self alertViewMethod:@"パスワード情報がありません"];
        return;
    }
    
    NSLog(@"Start Sending");
    SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
    emailMessage.fromEmail = gmailAddress; //送信者メールアドレス（Gmailのアカウント）
    emailMessage.toEmail = toMailAdress;                //宛先メールアドレス
    //emailMessage.ccEmail =@"cc@address";             //ccメールアドレス
    //emailMessage.bccEmail =@"bcc@address";         //bccメールアドレス
    emailMessage.requiresAuth = YES;
    emailMessage.relayHost = @"smtp.gmail.com";
    emailMessage.login = gmailAddress;         //ユーザ名（Gmailのアカウント）
    emailMessage.pass = pwString;                       //パスワード（Gmailのアカウント）
    //2段階認証プロセスを利用する場合、アプリパスワードを使用する
    emailMessage.subject =subjectString; //件名に記載する内容
    emailMessage.wantsSecure = YES;
    emailMessage.delegate = self;
    NSString *messageBody = @""; //メール本文に記載する内容
    NSDictionary *plainMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey, messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    //メールへの添付総まとめ配列（本文含む)
    NSMutableArray *mailParts = [NSMutableArray array];
    
    //本文格納
    [mailParts addObject:plainMsg];

    //メールの添付情報プロパティへ格納
    emailMessage.parts = mailParts;
    
    //メール送信
    [emailMessage send];
}

//gmail送信OK
-(void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"送信完了");
}


// gmail送信NG
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
        NSLog(@"Gmail送信失敗 - error(%ld): %@",(long)[error code],[error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"送れませんでした" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}


// ジオフェンスしっぱい。
-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"ジオフェンス領域%@しっぱい",region.identifier);
    NSLog(@"error=%@",error);
}


//ジオフェンスキャンセル
- (void)geoFenceCancel{
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        // 登録してある地点を全て取得し、停止
        [self.locationManager stopMonitoringForRegion:region];
        NSLog(@"cancel monotoring regions:%@", self.locationManager.monitoredRegions);
    }
    
}

//読み込み失敗時に呼ばれる関数
- (void)alertViewMethod:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

//バックグラウンド状態の時に通知する。
//-(void)LocalNotificationStart{
//    
//    //NSuserdefaultsから設定した時間を読み込む
//    NSUserDefaults *selectTimeDefault = [NSUserDefaults standardUserDefaults];
//    selectTimeFrom = [selectTimeDefault integerForKey:@"SELECTTIMEFIRST"];
//    NSLog(@"selectTimeFrom=%ld",selectTimeFrom);
//    selectTimeTo = [selectTimeDefault integerForKey:@"SELECTTIMEEND"];
//    NSLog(@"selectTimeTo=%ld",selectTimeTo);
//
//    
//    //現在時刻から取得した時間にユーザが選択した通知時刻をセットする
//    NSDate *today = [NSDate date];
//    NSCalendar *currentCalendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
//    dateComp = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth
//                                            | NSCalendarUnitDay  | NSCalendarUnitHour
//                                            | NSCalendarUnitMinute | NSCalendarUnitSecond )
//                                  fromDate:today];
////        dateComp.hour = selectTimeFrom;
//    dateComp.hour = 19;
////        dateComp.minute == selectTimeFrom
//    dateComp.minute = 41;
//        dateComp.second = 0;
//        
//        //アラートを作成
//        NSDate *notificationDate = [currentCalendar dateFromComponents:dateComp];
//        NSLog(@"notificationDate=%@",[notificationDate descriptionWithLocale:[NSLocale currentLocale]]);;
//        
//        //一度全ての通知をキャンセルさせる
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//        
//        UILocalNotification *notification = [[UILocalNotification alloc]init];
//        notification.fireDate = notificationDate;
//        notification.repeatInterval = NSCalendarUnitDay;
//        notification.shouldGroupAccessibilityChildren = YES;
//        notification.timeZone = [NSTimeZone defaultTimeZone];
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        notification.applicationIconBadgeNumber = -1;
//    notification.alertBody =@"test";
//        [[UIApplication sharedApplication]scheduleLocalNotification:notification];
//            
//}


//バックグラウンド通信
//-(void)LocalNotificationStart{
//        
//        //現在時刻から取得した時間にユーザが選択した開始時刻をセットする
//        NSDate *today = [NSDate date];
//        NSCalendar *currentCalendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        NSDateComponents *dateComp = [[NSDateComponents alloc] init];
//        dateComp = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth
//                                                | NSCalendarUnitDay  | NSCalendarUnitHour
//                                                | NSCalendarUnitMinute | NSCalendarUnitSecond )
//                                      fromDate:today];
//    NSLog(@"dateComp=%ld",(long)dateComp.hour);
//    
//    NSUserDefaults *selectTimeDefault = [NSUserDefaults standardUserDefaults];
//    selectTimeFrom = [selectTimeDefault integerForKey:@"SELECTTIMEFIRST"];
//    NSLog(@"selectTimeFrom=%ld",selectTimeFrom);
//    selectTimeTo = [selectTimeDefault integerForKey:@"SELECTTIMEEND"];
//    NSLog(@"selectTimeTo=%ld",selectTimeTo);
//    
//    NSInteger nowHour = (NSInteger)dateComp.hour;
//    if ((selectTimeFrom <= nowHour) && (nowHour <= selectTimeTo)) {
//        //5分に一回ロケーションマネージャを立ち上げる
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getGpsData:)  userInfo:nil repeats:YES];
//            }
//}


//3分に一回ロケーションマネージャを立ち上げる（これはもう不要）
//- (void)fire{
////    self.timer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(getGpsData:)  userInfo:nil repeats:YES];
//    
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(getGpsData:)  userInfo:nil repeats:YES];
//}




//１時間に1回指定時間に達しているかチェックする。
- (void)runLoopMethod{
    NSTimer *mainTimer = [NSTimer timerWithTimeInterval:3600 target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
//    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
//    [[NSRunLoop currentRunLoop] addTimer: mainTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop mainRunLoop] addTimer: mainTimer forMode:NSDefaultRunLoopMode];
//    [runLoop addTimer:mainTimer forMode:NSRunLoopCommonModes];
}


//ユーザが指定した時間だけfireメソッドを呼ぶ
- (void)runLoop{
    NSDate *today = [NSDate date];
    NSCalendar *currentCalendar =  [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    dateComp = [currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth
                                            | NSCalendarUnitDay  | NSCalendarUnitHour
                                            | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                  fromDate:today];
    
    NSUserDefaults *selectTimeDefault = [NSUserDefaults standardUserDefaults];
    selectTimeFrom = [selectTimeDefault integerForKey:@"SELECTTIMEFIRST"];
    NSLog(@"selectTimeFrom=%ld",selectTimeFrom);
    selectTimeTo = [selectTimeDefault integerForKey:@"SELECTTIMEEND"];
    NSLog(@"selectTimeTo=%ld",selectTimeTo);
    
    
    //３分に一回GPSをゲットする
    NSTimer *subTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(getGpsData:) userInfo:nil repeats:YES];
    //セットした時間内だけGPSを取得する
    if (selectTimeFrom <= (long)dateComp.hour){
        if((long)dateComp.hour < selectTimeTo){
//        [self fire];
            [[NSRunLoop currentRunLoop] addTimer: subTimer forMode:NSDefaultRunLoopMode];
            NSLog(@"時間内");
        }else{
        if ([subTimer isValid]) {
            [subTimer invalidate];
            }
            NSLog(@"最後の時間より後");
        }
    }else{
        if ([subTimer isValid]) {
            [subTimer invalidate];
        }
        NSLog(@"最初の時間より前");
    }
}

// 常に回転させない
- (BOOL)shouldAutorotate
{
    return NO;
}

// 縦のみサポート
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (IBAction)searchButtonTapped:(id)sender {
    [self locationAuth];
    locationSearch = YES;
    NSLog(@"locationSearch=%d",locationSearch);
    [self performSegueWithIdentifier:@"regviewToYahooview" sender:self];
}




@end

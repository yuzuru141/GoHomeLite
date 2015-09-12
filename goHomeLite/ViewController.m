//
//  ViewController.m
//  goHomeLite
//
//  Created by 石井嗣 on 2014/12/17.
//  Copyright (c) 2014年 YuZ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self viewBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewBackground{
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    
    //自分のメールラベル
    CGRect mailLabelRect = CGRectMake(width/10, height/9, width-width/10*2, 35);
    UILabel *mailLabel = [[UILabel alloc]initWithFrame:mailLabelRect];
    mailLabel.text = @"自分のgmailアドレス";
    [self.view addSubview:mailLabel];
    
    //自分のメールtextfield
    CGRect mailTextRect = CGRectMake(width/10+40, height/9+30, width-width/10*2, 35);
    UITextField *mailTextfield = [[UITextField alloc]initWithFrame:mailTextRect];
    NSString *mailString = [mydefault objectForKey:@"GMAIL"];
    if (mailString == nil || [ mailString isEqualToString:@""]){
        mailTextfield.placeholder = @"***@gmail.com";
    }else{
        mailTextfield.text = mailString;
    }
    //    textfield.layer.cornerRadius =3;
    mailTextfield.tag = 0;
    mailTextfield.returnKeyType = UIReturnKeyDefault;
    mailTextfield.keyboardType = UIKeyboardTypeEmailAddress;
    mailTextfield.delegate = self;
    [self.view addSubview:mailTextfield];
    
    //自分のメールPWラベル
    CGRect pwLabelRect = CGRectMake(width/10, height/9*2, width-width/10*2, 35);
    UILabel *pwLabel = [[UILabel alloc]initWithFrame:pwLabelRect];
    pwLabel.text = @"gmailパスワード";
    [self.view addSubview:pwLabel];
    
    //自分のメールPWtextfield
    CGRect pwTextRect = CGRectMake(width/10+40, height/9*2+30, width-width/10*2, 35);
    UITextField *pwTextfield = [[UITextField alloc]initWithFrame:pwTextRect];
    NSString *pwString = [mydefault objectForKey:@"PASSWORD"];
    if (pwString == nil || [ pwString isEqualToString:@""]){
        pwTextfield.placeholder = @"password";
    }else{
        NSInteger lengthInt = [pwString length];
        NSString *shadowPwStirng = @"*";
        for (int i; i<lengthInt; i++) {
            shadowPwStirng =[shadowPwStirng stringByAppendingString:@"*"];
        }
        pwTextfield.text = shadowPwStirng;
    }
    //    textfield.layer.cornerRadius =3;
    pwTextfield.tag = 1;
    pwTextfield.returnKeyType = UIReturnKeyDefault;
    pwTextfield.keyboardType = UIKeyboardTypeEmailAddress;
    pwTextfield.delegate = self;
    [self.view addSubview:pwTextfield];
    
    
    //登録ラベル
    CGRect targetMainLabelRect = CGRectMake(width/10, height/9*3, width-width/10*2, 35);
    UILabel *targetMainLabel = [[UILabel alloc]initWithFrame:targetMainLabelRect];
    targetMainLabel.text = @"宛先登録";
    [self.view addSubview:targetMainLabel];
    
    //宛先登録スイッチ
    CGRect regRect = CGRectMake(width/10, height/9*3+30, width-width/10*2, 35);
    UIButton *regButton =[UIButton buttonWithType:UIButtonTypeContactAdd];
    regButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [regButton sizeToFit];
    regButton.frame = regRect;
    regButton.tag = 0;
    [regButton addTarget:self action:@selector(toRegView:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:regButton];
    
    //登録先情報ラベル
    CGRect targetLabelRect = CGRectMake(width/10+40, height/9*3+30, width-width/10*2, 35);
    UILabel *targetLabel = [[UILabel alloc]initWithFrame:targetLabelRect];
    NSString *targetString = [mydefault objectForKey:@"PLACE"];
    NSLog(@"targetString=%@",targetString);
    if (![targetString isEqualToString:nil]){
        targetLabel.text = targetString;
    }
    [self.view addSubview:targetLabel];
    
    

}


//textfieldでリターンキーが押されるとキーボードを隠す。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSUserDefaults *mydefault = [NSUserDefaults standardUserDefaults];
    if (textField.tag == 0) {
        //全角チェック
        if(![textField.text canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            [self alertViewMethod:@"半角英数字とアルファベットで入力してください"];
        }else{
            //@gmailが含まれているかチェック
            NSRange range = [textField.text rangeOfString:@"@gmail"];
            if (range.location != NSNotFound) {
                if ([textField.text rangeOfString:@" "].location != NSNotFound) {
                    //空文字チェック
                    [self alertViewMethod:@"メールアドレスにスペースが入っていますので、確認してください"];
                }else{
                    NSLog(@"@gmail発見");
                    [mydefault setObject:textField.text forKey:@"GMAIL"];
                    NSLog(@"GMAIL=%@",textField.text);
                }
            } else {
                NSLog(@"@gmailない");
                [self alertViewMethod:@"適切なgmailアドレスを入力してください"];
            }
        }
    }else if(textField.tag == 1){
        //全角チェック
        if(![textField.text canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            [self alertViewMethod:@"半角英数字とアルファベットで入力してください"];
        }else{
            if ([textField.text rangeOfString:@" "].location != NSNotFound) {
                //空文字チェック
                [self alertViewMethod:@"メールアドレスにスペースが入っていますので、確認してください"];
            }else{
                [mydefault setObject:textField.text forKey:@"PASSWORD"];
                NSLog(@"PASSWORD=%@",textField.text);
                //PWを*で隠す
                
                NSInteger lengthInt = [textField.text length];
                NSString *shadowPwStirng = @"*";
                for (int i; i<lengthInt; i++) {
                    shadowPwStirng =[shadowPwStirng stringByAppendingString:@"*"];
                    NSLog(@"shadowPwString=%@",shadowPwStirng);
                }
                textField.text = shadowPwStirng;
            }
        }
    }else if(textField.tag == 2){

    }
    [mydefault synchronize];
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)toRegView:(id)sender{
    
    //tag情報をnsuserdefaultへ保存して、RegViewControllerへ

    //RegViewControllerへ移動
    [self performSegueWithIdentifier:@"viewToRegview" sender:self];
    
    
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


@end

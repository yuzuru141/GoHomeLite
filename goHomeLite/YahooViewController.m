//
//  YahooViewController.m
//  goHomeLite
//
//  Created by 石井嗣 on 2014/12/17.
//  Copyright (c) 2014年 YuZ. All rights reserved.
//

#import "YahooViewController.h"

@interface YahooViewController ()

@property NSMutableArray *nameArray;
@property NSMutableArray *locationArray;
@property NSMutableArray *addressArray;


@end

@implementation YahooViewController{
    NSString *addressStr;
}

NSString * const APIKEY = @"dj0zaiZpPUFCT0pHYU9MT0RObiZzPWNvbnN1bWVyc2VjcmV0Jng9ZmY-";


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewBackground];
    
}

-(void)viewBackground{
    
    //スクリーンサイズの取得
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    
    CGFloat width = screenSize.size.width;
    CGFloat height = screenSize.size.height;
    CGRect rect = CGRectMake(0, height/10, width, height-height/10);
    self.TableView = [[UITableView alloc]initWithFrame:rect];
    [self.view addSubview:self.TableView];
    self.TableView.delegate = self;
    self.TableView.dataSource = self;
    
    self.searchField = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, width, height/10)];
    [self.view addSubview:self.searchField];
    
    _searchField.delegate = self;
    _searchField.placeholder = @"e.g. company name, school name";
    
}

-(void)getJsonFromWord:(NSString *)word{
    
    _nameArray = [[NSMutableArray alloc]init]; //名前一覧格納
    _locationArray = [[NSMutableArray alloc]init]; //緯度経度格納
    _addressArray = [[NSMutableArray alloc]init]; //表示住所格納
    
    // UTF-8でエンコード
    NSString *encodedString = [word stringByAddingPercentEscapesUsingEncoding:
                               NSUTF8StringEncoding];
    
    //初動として20件のみ取得
    NSString *path = [NSString stringWithFormat:@"http://search.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid=%@&device=mobile&query=%@&results=20&output=json",APIKEY,encodedString];
    
    
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSHTTPURLResponse* resp;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:nil];
    
    //通信エラーであれば、警告を出す
    if (resp.statusCode != 200){
        [self alertViewMethod];
        return;
    }
    
    
    //WebAPIからNSData形式でJSONデータを取得
    NSData *jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if(jsonData){
        
        NSError *jsonParsingError = nil;
        //JSONからNSDictionaryまたはNSArrayに変換
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonParsingError];
        
        NSArray *arrayResult = [dic objectForKey:@"Feature"];
        
        if(arrayResult.count != 0){
            
            for(int i = 0 ; i < arrayResult.count ; i++){
                
                NSDictionary *resultDic = [arrayResult objectAtIndex:i];
                
                //表示名
                NSString *storeName = [resultDic objectForKey:@"Name"];
                if (![storeName isEqualToString:nil]) {
                    [_nameArray addObject:storeName];
                    NSLog(@"storeName=%@",storeName);
                }
                
                //緯度経度情報
                NSMutableDictionary *tempgeomerty = [resultDic objectForKey:@"Geometry"];
                NSString *geometry = [tempgeomerty objectForKey:@"Coordinates"];
                NSLog(@"geometry=%@",geometry);
                if (![geometry isEqualToString:nil]) {
                    [_locationArray addObject:geometry];
                }
                
                //緯度経度を２つに分割する
                NSArray *locations = [geometry componentsSeparatedByString:@","];
                NSString *stringLon = locations[0];
                NSString *stringLat = locations[1];
                double doubleLon = stringLon.doubleValue;
                double doubleLat = stringLat.doubleValue;
                
                //住所に変換
                NSString *address = [self getAddressFromLat:doubleLat AndLot:doubleLon];
                if (![address isEqualToString:nil]) {
                    [_addressArray addObject:address];
                    NSLog(@"address=%@",address);
                }
            }
            
            
        }else if(arrayResult.count == 0){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"no result"
                                                           message:@"There is no result."
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"search another word", nil];
            [alert show];
        }
        
    }else{
        
        NSLog(@"the connection could not be created or if the download fails.");
        [self alertViewMethod];
    }
}

//読み込み失敗時に呼ばれる関数
- (void)alertViewMethod{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkConncetionError", nil)
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
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
              [self alertViewMethod];//アラートビュー出す
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  _nameArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = _nameArray[indexPath.row];
    cell.detailTextLabel.text = _addressArray[indexPath.row];
    
    return cell;
}


//セルタップ時に呼び出される
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //必要な情報取得
    NSString *name = [_nameArray objectAtIndex:indexPath.row];
    NSString *location = [_locationArray objectAtIndex:indexPath.row];
    
    //緯度経度を２つに分割する
    NSArray *locations = [location componentsSeparatedByString:@","];
    NSString *lon1 = locations[0];
    NSString *lat1 = locations[1];
    double lon2 = lon1.doubleValue;
    double lat2 = lat1.doubleValue;
    
    //nsuserdefaultにデータを追加
    NSUserDefaults *placeDefault = [NSUserDefaults standardUserDefaults];
    [placeDefault setObject:name forKey:@"PLACE"];
    [placeDefault setDouble:lon2 forKey:@"LON"];
    [placeDefault setDouble:lat2 forKey:@"LAT"];
    [placeDefault synchronize];
    
    //確認用
//    NSString* nameplace = [placeDefault stringForKey:@"PLACE"];
//    NSLog(@"nameplace=%@",nameplace);
//    double lon3 = [placeDefault doubleForKey:@"LON"];
//    NSLog(@"lon3=%f",lon3);
//    double lat3 = [placeDefault doubleForKey:@"LAT"];
//    NSLog(@"lat3=%f",lat3);
    
    //アラート表示
    UIAlertView *alert =
    [[UIAlertView alloc]initWithTitle:@"complete"
                              message:@"You added the place for target"
                             delegate:nil
                    cancelButtonTitle:nil
                    otherButtonTitles:@"OK", nil];
    [alert show];
    
    //画面を一旦クリアする
    _nameArray = nil;
    _addressArray = nil;
    _locationArray = nil;
    
    [self.TableView reloadData];
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"YahooviewToRegview" sender:self];

}




//サーチボタンタップ時に呼ばれる
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSString *word = _searchField.text;
    [_searchField resignFirstResponder];
    [self getJsonFromWord:word];
    
    [self.TableView reloadData];
    
}


-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //
    //  NSLog(@"%dのセルが表示完了したときの動作　追加するときに書く",indexPath.row);
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIColor *backcolor = [UIColor whiteColor];
    UIColor *alpha = [backcolor colorWithAlphaComponent:0.0];
    cell.backgroundColor = alpha;
    
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

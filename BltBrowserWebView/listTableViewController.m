//
//  listTableViewController.m
//  BltBrowser
//
//  Created by lsq on 16/9/21.
//  Copyright © 2016年 blt. All rights reserved.
//

#import "listTableViewController.h"
#import "BLTWebViewViewController.h"

@interface listTableViewController ()
@property (nonatomic) NSMutableArray *tableArray;
@end

@implementation listTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _tableArray = [NSMutableArray array];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"baidu",@"name", @"https://baidu.com",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"svn",@"name", @"https://svnchina.com/svn/nk/",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"error",@"name", @"http://localhost:6571/errors/error.html?url=nttps://mozilla.com/",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"weibo",@"name", @"http://weibo.com",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"baidu云盘",@"name", @"https://pan.baidu.com",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"大犯罪者.倪匡.文字版.pdf",@"name", @"http://www.btbtt.la/attach-download-fid-1151-aid-3453254.htm",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"《没有凶手的杀人夜》（东野圭吾）",@"name", @"http://www.btbtt.la/attach-download-fid-1151-aid-3453261.htm",@"url", nil]];
    [_tableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"长网页",@"name", @"http://mp.weixin.qq.com/s?__biz=MTU1NjI5NTE4MQ==&mid=2649909331&idx=1&sn=b7069c6828c3888a884327bf170f1fea&chksm=6cfa11315b8d9827aa264f893a289f76dfed4c0973961edd4132181b2a8057151400239518f2&mpshare=1&scene=1&srcid=1009sFgjnnx0vOP3Wvoent4a#rd",@"url", nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"list";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",_tableArray[indexPath.row][@"name"],_tableArray[indexPath.row][@"url"]];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *strUrl =_tableArray[indexPath.row][@"url"];
    BLTWebViewViewController *vc = [[BLTWebViewViewController alloc]initWithUrlStr:strUrl];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

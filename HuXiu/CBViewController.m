//
//  CBViewController.m
//  HuXiu
//
//  Created by ly on 13-6-29.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import "CBViewController.h"
#import "CBContentViewController.h"
#import "CBRssParser.h"
#import "CBItem.h"
#import "AFNetworking.h"
#import <AVOSCloud/AVOSCloud.h>
#import "LocalInfo.h"

#import "MJRefresh.h"

#define RssFilePath    PathForXMLResource(@"0")

@interface CBViewController ()<MJRefreshBaseViewDelegate,UITableViewDelegate,UITableViewDataSource>{
         MJRefreshHeaderView *_header;
        UITableView *_tableview;
}

@end

@implementation CBViewController
{
    UIImage *placeHolder;
}

#define ShowAlerViewWithMessage(msg) \
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil \
        cancelButtonTitle:NSLocalizedString(@"好", @"OK") otherButtonTitles:nil] show];

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    placeHolder = [UIImage imageNamed:@"image-placeholder-20140917.png"];
    self.title = @"微信运营日报";

    [self.activityIndicator startAnimating];
    self.automaticallyAdjustsScrollViewInsets = YES;
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    _tableview.frame = CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64);
    [self.view addSubview:_tableview];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    http://www.huxiu.com/rss/0.xml
//    http://songshuhui.net/feed
//    http://www.zhihu.com/rss
//    http://feed.36kr.com/c/33346/f/566026/index.rss
    
    
//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:URLFromString(@"http://www.zhihu.com/")];
//    [client getPath:@"rss" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSString *rss = nil;
//        if ([responseObject isKindOfClass:[NSData class]]) {
//            rss = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        } else {
//            rss = (NSString *)responseObject;
//        }
//        
//        CBRssParser *parser = [[CBRssParser alloc] initWithRssFile:rss];
//        parser.delegate = self;
//        [parser parse];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self.activityIndicator stopAnimating];
//        
//        ShowAlerViewWithMessage(@"获取信息失败");
//    }];


    
    _header = [[MJRefreshHeaderView alloc] init];
    _header.scrollView = _tableview;
    _header.delegate = self;
    
   [_header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:0.5];

}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == _header) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncRssItemsState:) name:@"syncRssItemsState" object:nil];
        
        [self loadAvosData];
        
    }
}

- (void)loadAvosData
{
    AVQuery *article = [AVQuery queryWithClassName:@"Article"];
    [article orderByDescending:@"createdAt"];
    [article findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.activityIndicator stopAnimating];
        if (!error) {
            // The find succeeded.
            NSMutableArray *articleArray = [[NSMutableArray alloc] init];
            int i;
            for (i = 0; i < objects.count; i++) {
                NSLog(@"%@",[objects[i] objectForKey:@"link"]);
                CBItem *item = [[CBItem alloc] init];
                item.link = URLFromString([objects[i] objectForKey:@"link"]);
                item.title = [objects[i] objectForKey:@"title"];
                NSString *imageUrl = [objects[i] objectForKey:@"coverImage"];
                if(imageUrl == nil){
                    imageUrl = @"http://pic.iresearch.cn/news/201307/d8adbf34-565e-4406-92c5-cd19799d327b.jpg";
                }
                item.imageURL = [NSURL URLWithString:imageUrl];
                [articleArray addObject:item];
            }
            
            self.items = articleArray;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"syncRssItemsState" object:nil];
        } else {
            // Log details of the failure
            ShowAlerViewWithMessage(@"获取信息失败");
        }
    }];
}

- (void)syncRssItemsState:(NSNotification*)notify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncRssItemsState" object:nil];
    [_header endRefreshing];
    [_tableview reloadData];
}

//- (void) viewWillAppear:(BOOL)animated {
//    [_header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:0.5];
//}

- (void)CBRssParser:(CBRssParser *)parser didParseWithResult:(id)result
{
    _items = result;
    [self.activityIndicator stopAnimating];
    [_tableview reloadData];
}

#pragma mark - Table data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"%d",[self.items count]);
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if ( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CBItem *item = self.items[indexPath.row];

//    cell.textLabel.text = item.title;
//    cell.detailTextLabel.text = item.shortDesc;
//    cell.detailTextLabel.text = @"写点什么好呢？";
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cell.imageView setImageWithURL:item.imageURL placeholderImage:placeHolder];
    

    UIImageView *articleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 56, 42)];
    [articleImageView setImageWithURL:item.imageURL placeholderImage:placeHolder];
    [cell addSubview:articleImageView];
    
    UILabel *articleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 10, 235, 40)];
    articleTitleLabel.font = [UIFont systemFontOfSize:16.0f];
    articleTitleLabel.numberOfLines = 0;
    articleTitleLabel.text = item.title;
    articleTitleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [cell addSubview:articleTitleLabel];
    
//    UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(5, 59, 310, 1)];
//    banner.image = [UIImage imageNamed:@"banner-gray.png"];
//    [cell addSubview:banner];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(5, 59.5, 310, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1.0];
    [cell addSubview:line];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBItem *item = [self.items objectAtIndex:indexPath.row];
    
    CBContentViewController *contentViewController = [[CBContentViewController alloc] initWithNibName:@"CBContentViewController" bundle:nil];
    contentViewController.requestURL = item.link;
//    NSLog(@"%@",contentViewController.requestURL);
    [self.navigationController pushViewController:contentViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end

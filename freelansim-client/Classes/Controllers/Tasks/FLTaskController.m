//
//  FLTaskControllerViewController.m
//  freelansim-client
//
//  Created by Кирилл Кунст on 17.12.12.
//  Copyright (c) 2012 Kirill Kunst. All rights reserved.
//

#import "FLTaskController.h"
#import "FLHTMLUtils.h"
#import "SVProgressHUD.h"
#import "FLHTTPClient.h"
#import "FLManagedTask.h"

@interface FLTaskController ()
{
    int scrollViewHeight;
}
@end

@implementation FLTaskController

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
    self.loadingView.backgroundColor = [UIColor patternBackgroundColor];
    self.view.backgroundColor = [UIColor patternBackgroundColor];
    [super viewDidLoad];
    
    
    
    [[FLHTTPClient sharedClient] loadTask:self.task withSuccess:^(FLTask *task, AFHTTPRequestOperation *operation, id responseObject) {
        self.task = task;
        [self initUI];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setDescriptionWebView:nil];
    [self setViewsLabel:nil];
    [self setCommentsLabel:nil];
    [self setPublishedLabel:nil];
    [self setSkillsView:nil];
    [self setMainScrollView:nil];
    [self setLoadingView:nil];
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init Content
-(void)initUI {
    self.loadingView.hidden = YES;
    
    scrollViewHeight = 159;
    
    self.statView.layer.borderWidth = 1.0f;
    self.statView.layer.borderColor = [UIColor colorWithRed:0.31 green:0.38 blue:0.45 alpha:1].CGColor;
    self.statView.backgroundColor = [UIColor clearColor];
    self.statView.layer.cornerRadius = 5.0f;
    
    
    self.navigationItem.title = self.task.title;
    self.titleLabel.text = self.task.title;
    self.publishedLabel.text = self.task.datePublishedWithFormatting;
    self.viewsLabel.text = [NSString stringWithFormat:@"%d",self.task.viewCount];
    self.commentsLabel.text = [NSString stringWithFormat:@"%d",self.task.commentCount];
    
    self.descriptionWebView.scrollView.bounces = NO;
    self.descriptionWebView.delegate = self;
    self.descriptionWebView.opaque = NO;
    self.descriptionWebView.backgroundColor = [UIColor clearColor];
    
    [self loadHTMLContent];
    [self generateSkillTags];
    self.mainScrollView.contentSize = CGSizeMake(320,scrollViewHeight);
    [self initTopBar];
    
}
-(void)initTopBar {
    NSString *star;
    if([self isInFavourites]){
        star = @"cell-checkmark.png";
    }else{
        star = @"cell-checkmark-highlighted.png";
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32, 32);
    [button setImage:[UIImage imageNamed:star] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(favoritesClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *openInBrowserItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(actionOpenInBrowser:)];
    
    self.navigationItem.rightBarButtonItems = @[openInBrowserItem, item];
}
-(void)loadHTMLContent {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *html = [FLHTMLUtils formattedDescription:self.task.htmlDescription filesInfo:self.task.filesInfo];
    [self.descriptionWebView loadHTMLString:html baseURL:baseURL];
}
-(void)generateSkillTags {
    DWTagList *tagList = [[DWTagList alloc] initWithFrame:self.skillsView.frame];
    CGRect frame = tagList.frame;
    frame.origin.y = 30;
    [tagList setFrame:frame];
    [tagList setTags:self.task.tags];
    [self.skillsView addSubview:tagList];
    [self.skillsView sizeToFit];
    self.skillsView.backgroundColor = [UIColor clearColor];
}
-(BOOL)isInFavourites{
    NSArray *results = [FLManagedTask MR_findByAttribute:@"link" withValue:self.task.link];
    if([results count] > 0)
        return YES;
    return NO;
}
-(void)addToFavourites{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    FLManagedTask *managedTask = [FLManagedTask MR_createInContext:localContext];
    managedTask.dateCreated = [NSDate date];
    [managedTask mapWithTask:self.task];
    [localContext MR_saveWithOptions:MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        
    }];
    NSArray *results = [FLManagedTask MR_findAll];
    for(FLManagedTask *task in results){
        NSLog(@"%@", task.title);
    }
}
-(void)removeFromFavourites{
    NSArray *results = [FLManagedTask MR_findByAttribute:@"link" withValue:self.task.link];
    for(FLManagedTask *task in results){
        [task MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveWithOptions:MRSaveSynchronously completion:^(BOOL success, NSError *error) {
        
    }];
}
-(void)actionOpenInBrowser:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.task.link]];
}

#pragma mark - WebView Delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.descriptionWebView sizeToFit];
    scrollViewHeight += self.descriptionWebView.frame.size.height + 20;
    
    CGRect skillViewFrame = self.skillsView.frame;
    skillViewFrame.origin.y = self.descriptionWebView.frame.origin.y + self.descriptionWebView.frame.size.height + 10;
    
    self.skillsView.frame = skillViewFrame;
    self.mainScrollView.contentSize = CGSizeMake(320,scrollViewHeight + self.skillsView.frame.size.height);
}
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

-(void)favoritesClicked{
    if([self isInFavourites]){
        [self removeFromFavourites];
    }else{
        [self addToFavourites];
    }
    [self initTopBar];
}

@end

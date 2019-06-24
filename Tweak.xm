@interface XHRedEnvelopParam : NSObject
- (NSDictionary *)toParams;
@property (strong, nonatomic) NSString *msgType;
@property (strong, nonatomic) NSString *sendId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *headImg;
@property (strong, nonatomic) NSString *nativeUrl;
@property (strong, nonatomic) NSString *sessionUserName;
@property (strong, nonatomic) NSString *timingIdentifier;
@end
@implementation XHRedEnvelopParam
- (NSDictionary *)toParams {
    return @{
             @"msgType": self.msgType,
             @"sendId": self.sendId,
             @"channelId": self.channelId,
             @"nickName": self.nickName,
             @"headImg": self.headImg,
             @"nativeUrl": self.nativeUrl,
             @"sessionUserName": self.sessionUserName,
             @"timingIdentifier": self.timingIdentifier
             };
}
@end

@interface XHRedManager : NSObject
@property (nonatomic, strong) NSMutableArray *array;
//是否自动抢红包
@property (nonatomic, assign) BOOL isAutoRed;
+(instancetype) sharedInstance;
//添加对象
-(void) addParams:(XHRedEnvelopParam *) params;
//获得对象
- (XHRedEnvelopParam *) getParams:(NSString *) sendId;
@end

@implementation XHRedManager
+(instancetype) sharedInstance{
    static XHRedManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[XHRedManager alloc] init];
    });
    return _instance;
}

-(instancetype)init{
    if (self = [super init]){
        _array = [[NSMutableArray alloc] init];
    }
    return self;
}

//添加对象
-(void) addParams:(XHRedEnvelopParam *) params{
    @synchronized(self) {
        [_array addObject:params];
    }
}
//获得对象
- (XHRedEnvelopParam *) getParams:(NSString *) sendId{
    @synchronized(self) {
        NSInteger resultIndex = -1;
        for (NSInteger index = 0 ; index < self.array.count ; index++) {
            XHRedEnvelopParam *params = self.array[index];
            if ([params.sendId isEqualToString:sendId]){ //找到了
                resultIndex = index;
            }
        }
        if (resultIndex != -1 ){
            XHRedEnvelopParam *params = self.array[resultIndex];
            [self.array removeObjectAtIndex:resultIndex];
            return params;
        }
        return nil;
    }
}
//控制设置开关
- (void) handleRedSwitch{
    self.isAutoRed = !self.isAutoRed;
}
@end

@interface WCBizUtil
+ (id)dictionaryWithDecodedComponets:(id)arg1 separator:(id)arg2;
@end

@interface WCPayInfoItem
@property(copy, nonatomic) NSString *m_c2cNativeUrl;
@end

@interface CMessageWrap
@property(retain, nonatomic) WCPayInfoItem *m_oWCPayInfoItem;
@property(nonatomic) unsigned int m_uiMessageType; // @synthesize m_uiMessageType;
@property(retain, nonatomic) NSString *m_nsMsgSource; // @synthesize m_nsMsgSource;
@property(retain, nonatomic) NSString *m_nsBizChatId; // @synthesize m_nsBizChatId;
@property(retain, nonatomic) NSString *m_nsBizClientMsgID; // @synthesize m_nsBizClientMsgID;
@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;
@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsToUsr;
@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
@property(retain, nonatomic) NSString *m_nsAtUserList; // @synthesize m_nsAtUserList;
@property(retain, nonatomic) NSString *m_nsKFWorkerOpenID; // @synthesize m_nsKFWorkerOpenID;
@property(retain, nonatomic) NSString *m_nsDisplayName; // @synthesize m_nsDisplayName;
@property(retain, nonatomic) NSString *m_nsPattern; // @synthesize m_nsPattern;
@property(retain, nonatomic) NSString *m_nsRealChatUsr; // @synthesize m_nsRealChatUsr;
@property(retain, nonatomic) NSString *m_nsPushContent; // @synthesize m_nsPushContent;
@end

@interface WCRedEnvelopesControlData
@property(retain, nonatomic) CMessageWrap *m_oSelectedMessageWrap;
@property(retain, nonatomic) NSDictionary *m_structDicRedEnvelopesBaseInfo;
@end

@interface MMServiceCenter
+ (id)defaultCenter;
- (id)getService:(Class)arg1;
@end

@interface CContactMgr
- (id)getSelfContact;
@end

@interface CContact
@property(copy, nonatomic) NSString *m_nsHeadImgUrl;
@property(copy, nonatomic) NSString *m_nsUsrName;
- (NSString *)getContactDisplayName;
@end

@interface SKBuiltinBuffer_t
@property(retain, nonatomic) NSData *buffer;
@property(nonatomic) unsigned int iLen;
@end

@interface HongBaoRes
@property(retain, nonatomic) SKBuiltinBuffer_t *retText;
@end

@interface HongBaoReq
@property(nonatomic) unsigned int cgiCmd; // @dynamic cgiCmd;
@property(nonatomic) unsigned int outPutType; // @dynamic outPutType;
@property(retain, nonatomic) SKBuiltinBuffer_t *reqText; // @dynamic reqText;
@end


@interface WCRedEnvelopesLogicMgr
- (void)OpenRedEnvelopesRequest:(id)arg1;
- (void)ReceiverQueryRedEnvelopesRequest:(id)arg1;
@end

@interface MMTableView
- (void)reloadData;
@end



@interface WCTableViewManager
@property(retain, nonatomic) MMTableView *tableView; // @synthesize
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;
- (id)getTableView;
@end

@interface WCTableViewSectionManager
+ (id)defaultSection;
- (void)addCell:(id)arg1;
@end

@interface WCTableViewCellManager
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3;
+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(_Bool)arg4;
@end

@interface NewSettingViewController
{
    WCTableViewManager *m_tableViewMgr;
}
@end

////消息到来
%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
    %orig;
    NSInteger uiMessageType = [wrap m_uiMessageType];
    if ( 49 == uiMessageType && [XHRedManager sharedInstance].isAutoRed){ //红包消息,且开关打开
        NSString *nsFromUsr = [wrap m_nsFromUsr];
        //抢红包
        NSLog(@"收到红包消息");
        WCPayInfoItem *payInfoItem = [wrap m_oWCPayInfoItem];
        if (payInfoItem == nil) {
            NSLog(@"payInfoItem is nil");
            return;
        }
        NSString *m_c2cNativeUrl = [payInfoItem m_c2cNativeUrl];
        if (m_c2cNativeUrl == nil) {
            NSLog(@"m_c2cNativeUrl is nil");
            return;
        }
        NSInteger length = [@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length];
        NSString *subStr  = [m_c2cNativeUrl substringFromIndex: length];
        NSDictionary *dic =  [%c(WCBizUtil) dictionaryWithDecodedComponets:subStr separator:@"&"];
        
        XHRedEnvelopParam *redEnvelopParam = [[XHRedEnvelopParam alloc] init];
        redEnvelopParam.msgType = @"1";
        NSString *sendId = [dic objectForKey:@"sendid"];
        redEnvelopParam.sendId = sendId;
        NSString *channelId = [dic objectForKey:@"channelid"];
        redEnvelopParam.channelId = channelId;
        CContactMgr *service =  [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
        if (service == nil) {
            NSLog(@"service is nil");
            return;
        }
        CContact *contact =  [service getSelfContact];
        NSString *displayName = [contact getContactDisplayName];
        redEnvelopParam.nickName = displayName;
        NSString *headerUrl =  [contact m_nsHeadImgUrl];
        redEnvelopParam.headImg = headerUrl;
        if (nil != wrap) {
            redEnvelopParam.nativeUrl = m_c2cNativeUrl;
        }
        redEnvelopParam.sessionUserName = nsFromUsr;
        //1.0 存储抢红包时需要的参数
        if (sendId.length > 0)   {
            [[XHRedManager sharedInstance] addParams:redEnvelopParam];
        }
        //2.0 收到红包就拆红包
        NSMutableDictionary *params = [NSMutableDictionary dictionary] ;
        if ([nsFromUsr hasSuffix:@"@chatroom"]){ //群红包
            [params setObject:@"0" forKey:@"inWay"]; //0:群聊，1：单聊
        }else {     //个人红包
            [params setObject:@"1" forKey:@"inWay"]; //0:群聊，1：单聊
        }
        [params setObject:sendId forKey:@"sendId"];
        [params setObject:m_c2cNativeUrl forKey:@"nativeUrl"];
        [params setObject:@"1" forKey:@"msgType"];
        [params setObject:channelId forKey:@"channelId"];
        [params setObject:@"0" forKey:@"agreeDuty"];
        WCRedEnvelopesLogicMgr *redEnvelopesLogicMgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(WCRedEnvelopesLogicMgr) class]];
        [redEnvelopesLogicMgr ReceiverQueryRedEnvelopesRequest:params];
    }
}
%end

%hook WCRedEnvelopesLogicMgr
- (void)OnWCToHongbaoCommonResponse:(HongBaoRes*)hongBaoRes Request:(HongBaoReq*)hongBaoReq{
//    %log;
    %orig;

    NSError *err;
    NSDictionary *bufferDic = [NSJSONSerialization JSONObjectWithData:hongBaoRes.retText.buffer options:NSJSONReadingMutableContainers error:&err];

    if (hongBaoRes == nil || bufferDic == nil){
        return;
    }
    if (hongBaoReq == nil){
        return;
    }
    if (hongBaoReq.cgiCmd == 3){
        int receiveStatus = [bufferDic[@"receiveStatus"] intValue];
        int hbStatus = [bufferDic[@"hbStatus"] intValue];
        if (receiveStatus == 0 && hbStatus == 2){
            // 没有这个字段会被判定为使用外挂
            NSString *timingIdentifier = bufferDic[@"timingIdentifier"];
            NSString *sendId = bufferDic[@"sendId"];
            if (sendId.length > 0 && timingIdentifier.length > 0){
                XHRedEnvelopParam *redEnvelopParam = [[XHRedManager sharedInstance] getParams:sendId];
                if (nil != redEnvelopParam ){
                    redEnvelopParam.timingIdentifier = timingIdentifier;
                    NSDictionary *paramDic = [redEnvelopParam toParams];
                    sleep(1);
                    WCRedEnvelopesLogicMgr *redEnvelopesLogicMgr = [[%c(MMServiceCenter) defaultCenter] getService:[%c(WCRedEnvelopesLogicMgr) class]];
                    if (nil != redEnvelopesLogicMgr){
                        [redEnvelopesLogicMgr OpenRedEnvelopesRequest:paramDic];
                    }
                    
                }
            }
        }
    }
    
}
%end

//设置页添加配置
%hook NewSettingViewController
- (void)reloadTableData{
//    %log;
    %orig;
    WCTableViewManager *tableViewInfo = MSHookIvar<id>(self,"m_tableViewMgr");
    WCTableViewSectionManager *sectionInfo = [%c(WCTableViewSectionManager) defaultSection];
    WCTableViewCellManager *cellInfo = [%c(WCTableViewCellManager) switchCellForSel:@selector(handleRedSwitch) target:[XHRedManager sharedInstance] title:@"微信小助手" on:[XHRedManager sharedInstance].isAutoRed];
    [sectionInfo addCell:cellInfo];
    [tableViewInfo insertSection:sectionInfo At:0];

    MMTableView *tableView = [tableViewInfo getTableView];
    [tableView reloadData];
}
%end
//
//  AppDelegate.m
//  IFly_Test
//
//  Created by Dawn on 14-3-9.
//  Copyright (c) 2014年 Dawn. All rights reserved.
//

#import "AppDelegate.h"


#define APPID @"531bd3c4"

@implementation AppDelegate

- (void) dealloc{
    self.window = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.window addSubview:startBtn];
    startBtn.frame = CGRectMake(60, 100, 200, 60);
    startBtn.backgroundColor = [UIColor lightGrayColor];
    
    
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 需要先登陆
    IFlySpeechUser *loginUser = [[IFlySpeechUser alloc] initWithDelegate:self];
    
    // user 和 pwd 都传入nil时表示是匿名登陆
    NSString *loginString = [[NSString alloc] initWithFormat:@"appid=%@",APPID];
    [loginUser login:nil pwd:nil param:loginString];
    [loginString autorelease];
    
    return YES;
}

- (void)startBtnClick:(id)sender{
    if (![IFlySpeechUser isLogin]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"正在登录……" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        // 需要先登陆
        IFlySpeechUser *loginUser = [[IFlySpeechUser alloc] initWithDelegate:self];
        
        // user 和 pwd 都传入nil时表示是匿名登陆
        NSString *loginString = [[NSString alloc] initWithFormat:@"appid=%@",APPID];
        [loginUser login:nil pwd:nil param:loginString];
        [loginString autorelease];
    }
    else {
        // 创建语义识别对象
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID];
        IFlySpeechRecognizer *iflySpeechRecognizer = [IFlySpeechRecognizer createRecognizer:initString delegate:self];
        //设置识别参数
        [iflySpeechRecognizer setParameter:@"domain" value:@"iat"];//普通听写服务
        [iflySpeechRecognizer setParameter:@"sample_rate" value:@"16000"];//录音采样率为16k
        [iflySpeechRecognizer setParameter:@"vad_bos" value:@"1800"];//前端点检测时间
        [iflySpeechRecognizer setParameter:@"vad_eos" value:@"6000"];//后端点检测时间
        [iflySpeechRecognizer setParameter:@"asr_sch" value:@"1"];//开启语义处理
        [iflySpeechRecognizer setParameter:@"plain_result" value:@"1"]; //解析识别内容
        [iflySpeechRecognizer setParameter:@"params" value:@"rst=json,nlp_version=2.0"];
        //[iflySpeechRecognizer setParameter:@"params" value:@"scn=weather"];//语义场景为天气
        
        //启动识别服务
        [iflySpeechRecognizer startListening];
    }
}


/** 登陆结束回调
 
 当本函数被调用的时候，表明登陆已经完成，可能失败或者成功。
 
 @param iFlySpeechUser      -[out] 登陆对象，
 @param error               -[out] 本次会话的错误对象，0表示没有错误
 */
- (void) onEnd:(IFlySpeechUser *)iFlySpeechUser error:(IFlySpeechError *)error{
    if(iFlySpeechUser.isLogin){
        NSLog(@"登陆成功");
    }else{
        NSLog(@"errorCode:%d errorDes:%@",error.errorCode,error.errorDesc);
    }
}

/** 识别结果回调
 
 在进行语音识别过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理，当errorCode没有错误时，表示此次会话正常结束；否则，表示此次会话有错误发生。特别的当调用`cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函数之前如果重新调用了`startListenging`函数则会报错误。
 
 @param errorCode 错误描述类，
 */
- (void) onError:(IFlySpeechError *) errorCode{
    NSLog(@"errorCode:%d errorDes:%@",errorCode.errorCode,errorCode.errorDesc);
}

/** 识别结果回调
 
 在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 
 使用results的示例如下：
 <pre><code>
 - (void) onResults:(NSArray *) results{
 NSMutableString *result = [[NSMutableString alloc] init];
 NSDictionary *dic = [results objectAtIndex:0];
 for (NSString *key in dic)
 {
 //[result appendFormat:@"%@",key];//合并结果
 }
 }
 </code></pre>
 
 @param   results     -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度。
 */
- (void) onResults:(NSArray *) results{
    //[NSJSONSerialization ]
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);
    [json release];
}


/** 音量变化回调
 
 在录音过程中，回调音频的音量。
 
 @param volume -[out] 音量，范围从1-100
 */
- (void) onVolumeChanged: (int)volume{
    NSLog(@"volume:%d",volume);
}

/** 开始录音回调
 
 当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。如果发生错误则回调onError:函数
 */
- (void) onBeginOfSpeech{
    NSLog(@"begin speech");
}

/** 停止录音回调
 
 当调用了`stopListening`函数或者引擎内部自动检测到断点，如果没有发生错误则回调此函数。如果发生错误则回调onError:函数
 */
- (void) onEndOfSpeech{
    NSLog(@"end speech");
}

/** 取消识别回调
 
 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 */
- (void) onCancel{
    NSLog(@"cancel");
}

@end

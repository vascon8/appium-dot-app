//
//  RecordScriptUploadResult.h
//  Appium
//
//  Created by xin liu on 15/1/26.
//  Copyright (c) 2015年 Appium. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RecordScriptUploadStatusType{
	RecordScriptUploadStatusSuccess,
	RecordScriptUploadStatusFail,
	RecordScriptUploadStatusUploading
}RecordScriptUploadStatus;

@interface RecordScriptUploadResult : NSObject

@property NSString *scriptName;
@property RecordScriptUploadStatus uploadStatus;
@property BOOL checked;

@end

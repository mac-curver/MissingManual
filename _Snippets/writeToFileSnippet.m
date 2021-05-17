


enum FileRecordingType {
      IdleRecordingType
    , RecordingType
    , RecordingType1
    , RecordingType2
    , FinishedRecordingType
};


@implementation WriteToFileSnippet


- (void) init:(NSString*)filename header:(NSString*)headerLine {
	testFilePath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] createFileAtPath:testFilePath 
    				contents:nil attributes:nil]
    ) {
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:testFilePath];
        [fileHandle writeData:[headerLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
    fileRecording = IdleRecordingType;
}

- (void) nextRecordingMode {
    fileRecording ++;
    if (FinishedRecordingType == fileRecording) {
        [fileHandle closeFile];
    }
}


- (void) doRecording {           
    switch (fileRecording) {
        case FinishedRecordingType:
        case IdleRecordingType:
            break;
        default:
            [fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
            break;
    }
}

@end



extern NSString       *testFilePath;
extern NSFileHandle   *fileHandle;

@interface WriteToFileSnippet {
	FileRecordingType		fileRecording;
}


- (void) init:(NSString*)filename header:(NSString*)headerLine;

- (void) nextRecordingMode;

- (void) doRecording;

@end







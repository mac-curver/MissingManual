# MissingManual
***
Xcode gradient objective-c sample code 

The first program is a gradient test sample code allowing to define a 2 step gradient and to retrieve the corresponding sample code. 

This SW displays a 2 point linear or radial gradient that can be manipulated by the mouse and entry of some parameters. The final generated code can be retrieved by the edit menu item: "_Edit: CopyGradientCode_".

According to the selected drawing context the generated code snippet uses pure quartz or alternatively core animation layer.

The TestView.m file can be used to test the generated code! This view will be displayed using: "_Window: ShowTestWindow..._".

### Remarks: 
> _To avoid plenty of C-style type cast I am using plenty of class categories. The UserDefaultExtension might be of general use, all others are locally defined as implementations only in TestGradient.m as they are quite specific to this application._

---
## History:
|Version|Date|Comment|
|----|-----|-------| 
|Version 2.3:|2023-03-14|Crash for 5 components color like device cmyk repaired|
|Version 2.2:|2021-06-17|Quartz circle also disappears, xcode documentation support added|
|Version 2.1:|2021-06-17|Potential leaks corrected|
|Version 2.0:|2021-06-16|First completely working version (No crash anymore)|
|Version 1.0:|2021-06-16|First trials (Working, but issues with retina and 2 component color spaces )|



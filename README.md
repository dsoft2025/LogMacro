# Swift Log Macros
 스위프트 코딩시에 편하게 사용할 수 있는 로그 출력용 매크로  
 print(...) 대체  
 [통합 로깅 시스템(Unified Logging System)](https://developer.apple.com/documentation/os/logging)을 사용하여 콘솔 앱에서도 확인 가능  
 Xcode Console 에서도 클릭 시 코드 위치로 이동 및 부가 정보 출력
## Log Macro 란
[스위프트 매크로(Swift Macro)](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)는 반복되는 코드 부분의 Boilerplate를 줄이기 위한 목적으로 활용되는 일종의 텍스트 변환(Expansion) 방법으로
컴파일러에 의해서 플러그인 형식으로 처리된다.
## 예제

### 전역 로그 - #log
```swift
#log(a + b)
#log("The value = \(result)")
#log(a, b, category: "test")
#log(a, b, 2)
```
### member 로그 - @Logging
```swift
@available(iOS 14.0, macOS 11.0, *)
@Logging
class Sample {
    init() {
        #mlog("init")
    }
    
    func doSomething() {
        #mlog("doSomething")
    }
}
```
## 기본 사용법
### Swift Package 추가
Xcode 프로젝트에 LogMacro를 패키지 종속성으로 추가하여 사용할 수 있습니다.

 1. 파일(File) 메뉴에서 **패키지 종속성 추가(Add Package Dependencies...)**를 선택합니다.
 2. 패키지 저장소 URL 입력란에 "https://github.com/dsoft2025/LogMacro"를 입력합니다.
 3. 프로젝트 구조에 따라 다음 단계를 진행합니다:
    - 하나의 애플리케이션 타겟만 이 라이브러리에 접근해야 한다면, LogMacro를 해당 애플리케이션에 직접 추가하면 됩니다.
    - 여러 개의 Xcode 타겟에서 이 라이브러리를 사용하거나, Xcode 타겟과 Swift 패키지(SPM) 타겟을 혼합해서 사용하려는 경우에는, LogMacro에 의존하는 공용 프레임워크를 만들어야 하며, 모든 타겟에서 그 프레임워크를 참조해야 합니다.
이런 방식의 예시로는 다양한 기능을 모듈로 분리하고 정적 라이브러리를 활용하는 데모 애플리케이션(작성 중)을 참고하세요.

### 전역 로그 
아래 와 같이 함수 형식으로 정의 되어 있다. 
```swift
public macro log(_ items: Any..., category: String = "Log")
```
예제에서와 같이 다양한 형태로 사용이 가능하다.  
아직은 완전히 print(...) 형식을 지원하지 못함  
*category*는 생략이 가능하다. 생략하면 기본 값은 "Log"  
  
iOS 10, macOS 10.12 이상에서 사용가능
### member 로그
```swift
@available(iOS 14.0, macOS 11.0, *)
public macro Logging() ...
```
```swift
public macro mlog(level: OSLogType = .default, _ items: Any..., category: String = "Log") = #externalMacro(module: "LogMacroMacros", type: "MemberLogMacro")
```
예제와 같이 @Logging 를 class 나 struct 에 추가하면
통합 로깅 시스템 [Logger](https://developer.apple.com/documentation/os/logger) 형식의 logger 이라는 멤버가 생성된다.  
멤버함수 등에서 #mlog("doSomething")와 같이 사용할 수 있다. 
  
iOS 14 이상, macOS 11 이상에서 사용가능  

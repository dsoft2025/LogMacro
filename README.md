# Swift Log Macros

스위프트 코딩시에 편하게 사용할 수 있는 로그 출력용 매크로  
print(...) 대체  
[통합 로깅 시스템(Unified Logging System)](https://developer.apple.com/documentation/os/logging)을 사용하여 콘솔 앱에서도 확인 가능  
Xcode Console 에서도 클릭 시 코드 위치로 이동 및 부가 정보 출력

## ✨ 최신 개선사항 (v0.5.5)

- **🔥 클로저 호환성 완전 지원**: `#mlog` 매크로가 이제 모든 클로저 환경에서 안전하게 작동
- **📦 듀얼 로깅 지원**: `Logger`와 `OSLog` 동시 지원으로 더 유연한 로깅 환경 제공
- **🔒 향상된 캡슐화**: private 접근 제어를 통한 더 안전한 API 설계
- **🧪 강화된 테스트**: 클로저 시나리오를 포함한 포괄적인 테스트 커버리지
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

### 멤버 로그 - @Logging
```swift
@available(iOS 14.0, macOS 11.0, *)
@Logging
class Sample {
    var count = 0
    
    init() {
        #mlog("초기화 완료")
    }
    
    func doSomething() {
        #mlog("작업 시작: count = \(self.count)")
        
        // ✨ 클로저에서도 안전하게 사용 가능!
        DispatchQueue.main.async {
            #mlog("비동기 작업 완료: count = \(self.count)")
        }
        
        let completion = { [weak self] in
            #mlog("completion 블록 실행: count = \(self?.count ?? 0)")
        }
        completion()
    }
}
```

### Actor에서의 사용
```swift
@available(iOS 14.0, macOS 11.0, *)
@Logging
actor Counter {
    private var value = 0
    
    func increment() {
        #mlog("increment 호출 전: \(self.value)")
        value += 1
        #mlog("increment 호출 후: \(self.value)")
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

### 전역 로그 - #log

#### 매크로 정의
```swift
public macro log(_ items: Any..., category: String = "Log")
```

#### 사용법
아래와 같이 함수 형식으로 사용 가능합니다:

```swift
let a = 17, b = 25
let result = a + b

#log(a + b)                           // 단일 값
#log("The value = \(result)")         // 문자열 보간
#log(a, b, category: "Math")          // 여러 값 + 카테고리
#log("사용자 \(userName) 로그인")      // 한글 지원
```

#### 특징
- **유연한 인자**: 여러 개의 값을 동시에 로깅 가능
- **카테고리 지원**: 로그를 체계적으로 분류
- **타입 자동 변환**: 모든 타입을 자동으로 문자열로 변환
- **성능 최적화**: 릴리즈 빌드에서 자동으로 비활성화

#### 시스템 요구사항
- iOS 10, macOS 10.12 이상에서 사용가능  
  
## 고급 사용법

### 로그 레벨 지정
```swift
@Logging
class ServiceManager {
    func processData() {
        #mlog(level: .info, "처리 시작")
        #mlog(level: .debug, "디버그 정보: \(detailInfo)")
        #mlog(level: .error, "오류 발생: \(errorMessage)")
        #mlog(level: .fault, "심각한 오류!")
    }
}
```

### 카테고리 지정으로 로그 분류
```swift
#log("일반 로그")
#log("네트워크 관련", category: "Network")
#log("데이터베이스 관련", category: "Database")

#mlog("멤버 로그")
#mlog("UI 업데이트", category: "UI")
```

### 실제 프로덕션 예제
```swift
@available(iOS 14.0, macOS 11.0, *)
@Logging
class UserManager {
    private var users: [User] = []
    
    func addUser(_ user: User) {
        #mlog(level: .info, "사용자 추가 시작: \(user.name)")
        
        users.append(user)
        
        // 비동기 저장 작업
        Task {
            do {
                try await saveToDatabase(user)
                #mlog(level: .info, "사용자 저장 완료: \(user.id)")
            } catch {
                #mlog(level: .error, "사용자 저장 실패: \(error.localizedDescription)")
            }
        }
    }
}
```

## 📚 추가 문서

- **[COMMIT_SUMMARY.md](./COMMIT_SUMMARY.md)**: 최신 개선사항의 기술적 세부 내용
- **[WORK_COMPLETION_REPORT.md](./WORK_COMPLETION_REPORT.md)**: 프로젝트 개선 과정 전체 보고서

## 🔧 문제 해결

### 자주 묻는 질문

**Q: 클로저에서 `#mlog` 사용 시 컴파일 에러가 발생해요**  
A: v0.5.5부터 완전히 해결되었습니다. 최신 버전으로 업데이트해주세요.

**Q: struct에서 `#mlog` 사용 시 mutating 오류가 발생해요**  
A: struct의 메서드에서 사용할 때는 `mutating` 키워드를 추가해주세요:
```swift
@Logging
struct DataProcessor {
    mutating func process() {
        #mlog("처리 중...")
    }
}
```

**Q: 로그가 Xcode 콘솔에 나타나지 않아요**  
A: DEBUG 빌드에서만 로그가 출력됩니다. 릴리즈 빌드에서는 성능을 위해 로그가 비활성화됩니다.

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 🤝 기여하기

버그 리포트, 기능 제안, 풀 리퀘스트 등 모든 형태의 기여를 환영합니다!
### 멤버 로그 - @Logging

#### 매크로 정의
```swift
@available(iOS 14.0, macOS 11.0, *)
public macro Logging() // Logger와 OSLog 인스턴스 자동 생성
```
```swift
public macro mlog(level: OSLogType = .default, _ items: Any..., category: String = "Log")
```

#### 기능 설명
예제와 같이 `@Logging`을 class, struct, actor에 추가하면 다음 두 개의 private 멤버가 자동으로 생성됩니다:

- **logger**: 통합 로깅 시스템 [Logger](https://developer.apple.com/documentation/os/logger) 인스턴스
- **osLog**: 레거시 호환성을 위한 [OSLog](https://developer.apple.com/documentation/os/oslog) 인스턴스

#### 클로저 지원 🎉
**v0.5.5부터 클로저 내부에서도 완전히 지원됩니다!**

```swift
@Logging
class NetworkManager {
    func fetchData() {
        #mlog("데이터 요청 시작")
        
        // 모든 종류의 클로저에서 안전하게 사용 가능
        URLSession.shared.dataTask(with: url) { data, response, error in
            #mlog("네트워크 응답 수신: \(response?.description ?? "nil")")
        }.resume()
        
        // DispatchQueue 클로저
        DispatchQueue.global().async {
            #mlog("백그라운드 작업 시작")
            
            DispatchQueue.main.async {
                #mlog("메인 스레드로 복귀")
            }
        }
    }
}
```

#### 지원 타입
- ✅ **Class**: 완전 지원
- ✅ **Struct**: 완전 지원 (lazy var로 구현되어 mutating 메서드에서 사용)
- ✅ **Actor**: 완전 지원

#### 시스템 요구사항
- iOS 14 이상, macOS 11 이상에서 사용가능
- iOS 10~13, macOS 10.12~10.15에서는 레거시 OSLog 방식으로 동작  

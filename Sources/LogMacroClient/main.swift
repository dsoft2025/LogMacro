import LogMacro

let a = 17
let b = 25

let (result, code) = (a + b, "a + b")

print("By print,", "The value \(result) was produced by the code \"\(code)\"")

#log(a + b)
#log("The value = \(result)")
#log(a, b,category: "test")
#log(a, b, 2)
#log(a,b, 1)
#log(a,b, result)
#log("The value \(result) was produced by the code \"\(code)\"")
let url = URL(string: "https://m.daum.net")
let data = code.data(using: String.Encoding.utf8)!
#log("response \(String(describing: url)) => \nsuccess : \(String(decoding: data, as: UTF8.self))")
let c: () = #log(b)
debugPrint("By debugPrint,", c, type(of: c), String(describing: c))
let d: () = c
print("By print,", type(of: d), d == ())
NSLog("By NSLog, \(type(of: d)), \(d == ())")
if #available(macOS 11.0, iOS 14.0, *) {
    os_log(.default, log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: "os_log"), "\(type(of: d)), \(d == ())")
}
os_log("%{public}@", log: OSLog(subsystem: LoggingMacroHelper.subsystem(), category: "os_log(old)"), "\(type(of: d)), \(d == ())")

@available(iOS 14.0, macOS 11.0, *)
@Logging
class Ele {
    var x: Int = 200
    init() {
        #if DEBUG
            logger.info("init")
        #endif
        #mlog("x = \(self.x)")
    }
    
    func doSomething() {
        let counter = Counter()
        Task {
            await counter.increment()
        }
#if DEBUG
        logger.debug("doSomething")
        logger.log("x = \(self.x)")
        logger.log(level: .error, "test test")
#endif
    }
}

@available(iOS 14.0, macOS 11.0, *)
@Logging
actor Counter {
    var count :Int = 0
    
    func increment() {
        #mlog("before count:\(self.count)")
        self.count += 1
        #mlog("after count:\(self.count)")
    }
}

@available(iOS 14.0, macOS 11.0, *)
@Logging
struct Struct {
    var x: Int = 200
    init() {
        #if DEBUG
            logger.info("init")
        #endif
//        #mlog("x = \(self.x)", category: "Struct")
//        #log("x = \(self.x)", category: "Struct")
        #log("log from Struct", category: "Struct")
        #mlog("mlog from Struct")
    }
    
    /**
    * mutating 이 필수
    */
    mutating func doSomething() {
#if DEBUG
        logger.debug("doSomething")
//        logger.log("x = \(self.x)")
        print("print By, x = \(x)")
        logger.log(level: .error, "test test")
#endif
    }
}

if #available(iOS 14.0, macOS 11.0, *) {
    let ele = Ele()
    ele.doSomething()
    
    let st = Struct()
    var stNew = st
    stNew.doSomething()
} else {
    #log("Fallback on earlier versions")
}

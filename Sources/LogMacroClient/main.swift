import LogMacro

let a = 17
let b = 25

let (result, code) = (a + b, "a + b")

print("The value \(result) was produced by the code \"\(code)\"")

#log(a + b)
#log("The value = \(result)")
#log(a, b,category: "test")
#log(a, b, 2)
#log(a,b, 1)
#log(a,b, result)
#log("The value \(result) was produced by the code \"\(code)\"")
let url = URL(string: "https://m.daum.net")
let data = code.data(using: String.Encoding.utf8)!
#log("response \(url) => \nsuccess : \(String(decoding: data, as: UTF8.self))")
let c: () = #log(b)
debugPrint(c, type(of: c), String(describing: c))
let d: () = c
print(type(of: d), d == ())

@available(iOS 14.0, macOS 11.0, *)
@Logging
class Ele {
    init() {
        logger.info("init")
    }
    
    func doSomething() {
        logger.info("doSomething")
    }
}

if #available(iOS 14.0, macOS 11.0, *) {
    let ele = Ele()
    ele.doSomething()
} else {
    #log("Fallback on earlier versions")
}

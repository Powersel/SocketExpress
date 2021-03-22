struct SocketExpress {
    var text = "Hello, World!"
}

public struct TestSocketExpress {
    
    let initialWord: String
    
    public init(with initialWord: String) {
        self.initialWord = initialWord
    }
    
    public func pp(word: String) {
        print(initialWord + word)
    }
}

struct SocketExpress {
    var text = "Hello, World!"
}

public struct TestSocketExpress {
    
    let initialWord: String = "Hello "
    
    public func pp(word: String) {
        print(initialWord + word)
    }
}

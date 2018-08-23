import Prelude
import Foundation

private var printCount = 0

public func p<X>(_ x: X) {
    printCount += 1
    pr(printCount)(x)
//    print(x)
}

public func pr<Ctx, X>(_ ctx: Ctx) -> (_ x: X) -> () {
    return { x in
        print("[\(ctx)]\t", x)
    }
}

infix operator ===>: AssignmentPrecedence

public func ===> <A, B> (f: (A) -> B, a: A) -> B {
    return f(a)
}

/// - Note: Pointfreeco's KeyPath-based Lens setter requires `private(set)` in struct data-type
/// - Attention: Is it a bug that `WritableKeyPath` can mutate `private(set) var` outside of data-type's framework?
/// https://bugs.swift.org/browse/SR-5218
/// https://bugs.swift.org/browse/SR-5214
public struct A {
    public private(set) var b1: B
    public private(set) var b2: B

    public init(b1: B, b2: B) {
        self.b1 = b1
        self.b2 = b2
    }
}

public struct B {
    public private(set) var c: C

    public init(c: C) {
        self.c = c
    }
}

public struct C {
    public private(set) var int: Int
    public private(set) var str: String

    public init(int: Int, str: String) {
        self.int = int
        self.str = str
    }
}

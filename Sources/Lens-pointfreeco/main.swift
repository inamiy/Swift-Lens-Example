import Helpers
import Prelude
import Either
import Optics

// This is an example of Pointfreeco's `swift-prelude/Optics`
// - Pointfreeco: https://github.com/pointfreeco/swift-prelude/blob/master/Sources/Optics/Setter.swift
//
// See also:
// - kickstarter: https://github.com/kickstarter/Kickstarter-Prelude/blob/master/Prelude/Lens.swift
// - typelift/Focus: https://github.com/typelift/Focus/blob/master/Sources/Focus/Lens.swift
// - to4ki/Monocle: https://github.com/to4iki/Monocle
//
// NOTE:
// - Pointfreeco's KeyPath-based Lens setter requires `private(set)` in struct data-type

// Haskell Lens:
// https://hackage.haskell.org/package/lens-4.17/docs/Control-Lens-Lens.html
//
// type Lens s t a b = forall f. Functor f => (a -> f b) -> s -> f t
// lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b
//
// (^.) :: s -> Getting a s a -> a
//
// (.~) :: ASetter s t a b -> b -> s -> t  -- replace
// (%~) :: ASetter s t a b -> (a -> b) -> s -> t  -- set with mapping
//
// (&) :: a -> (a -> b) -> b   -- x & f = f x, `infixl 1 &`
//
// >>> ("hello",("world","!!!")) ^. _2 . _1
// "world"
// >>> ("hello",("world","!!!")) & _2 . _1 .~ 42
// ("hello",(42,"!!!"))
// >>> ("hello",("world","!!!")) & _2 . _1 %~ map toUpper
// ("hello",("WORLD","!!!"))
//
// >>> view (_2 . _1) ("hello",("world","!!!"))
// "world"
// >>> set (_2 . _1) 42 ("hello",("world","!!!"))
// ("hello",(42,"!!!"))
// >>> over (_2 . _1) (map toUpper) ("hello",("world","!!!"))
// ("hello",("WORLD","!!!"))

let kp: WritableKeyPath = \A.b1

let b = B(c: C(int: 42, str: "b1"))
let b2 = B(c: C(int: -1, str: "b2"))
let a = A(b1: b, b2: b)

// getter
p ===> a .^ \.b1            // B(c: C(int: 42, str: "Hi"))
p ===> a .^ (\.b1 <<< \.c)  // C(int: 42, str: "Hi")
p ===> a .^ \.b1.c          // C(int: 42, str: "Hi")
p ===> "abc" .^ getting(\.count)        // 3
p ===> "abc" .^ \.count                 // 3
p ===> view(getting(\.count))("abc")    // 3

// setter
p ===> a |> (\.b1 /*over(\.b1)*/ .~ b2 )    // A(b1: B(c: C(int: -1, str: "b2")), b2: B(c: C(int: 42, str: "b1"))
p ===> a |> (\.b1.c.str %~ uppercased)      // A(b1: B(c: C(int: 42, str: "B1")), b2: B(c: C(int: 42, str: "b1")))
p ===> ((1, 2), 3) |> first <<< second .~ "Haha!"   // ((1, "Haha!"), 3)
p ===> Either<String, Either<String, Int>>.right(.right(1)) |> right <<< right .~ 999   // .right(.right(999))

let lens1: Setter<A, A, B, B> = lens(/*getter*/ { $0.b1 }, /*setter*/ uncurry(flip(set(\A.b1))))
p ===> (lens1 .~ b2)(a)     // C(int: -1, str: "b2")), b2: B(c: C(int: 42, str: "b1")))

let lens2: Setter<A, A, B, B> = over(\A.b1)
p ===> (lens1 .~ b2)(a)     // C(int: -1, str: "b2")), b2: B(c: C(int: 42, str: "b1")))

p ===> [1, 999, 2] .^ ix(1)     // 999
p ===> ["a": 999] .^ key("a")   // Optional(999)
p ===> ["a": 999] .^ key("b")   // nil
p ===> ["a": 999] |> key("a") <<< traversed +~ 1    // ["a": 1000]
p ===> ["a": 999] |> key("b") %~ { ($0 ?? 0) + 1 }  // ["b": 1, "a": 999]

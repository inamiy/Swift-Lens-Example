//: Playground - noun: a place where people can play

import Foundation
import Helpers

// https://gist.github.com/mbrandonw/4acd26ab01bb6140af69
// https://gist.github.com/mbrandonw/48ea2b3de9dc308907d9
// https://gist.github.com/mbrandonw/284c41a5dcf3837a2b43

//----------------------------------------
// Types
//----------------------------------------

struct Location {
    let name: String
}

struct User {
    let name: String
    let location: Location
}

struct Project {
    let name: String
    let creator: User
    let location: Location
}

extension Location : CustomDebugStringConvertible {
    var debugDescription: String {
        return "{\(name)}"
    }
}

extension User : CustomDebugStringConvertible {
    var debugDescription: String {
        return "{\(name), \(location)}"
    }
}

extension Project : CustomDebugStringConvertible {
    var debugDescription: String {
        return "{\(name), \(creator), \(location)}"
    }
}

let la = Location(name: "Los Angeles")
let joel = User(name: "Joel", location: la)

let mn = Location(name: "Minneapolis")
let mst3k = Project(
    name: "Bring Back MYSTERY SCIENCE THEATER 3000",
    creator: joel,
    location: mn)

//----------------------------------------
// Lens
//----------------------------------------

struct Lens <Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole
}

//----------------------------------------
// Example1
//----------------------------------------

let nameLens = Lens<User, String>(
    get: { user in user.name },
    set: { (name, user) in User(name: name, location: user.location) }
)

p ===> nameLens.get(joel)
p ===> nameLens.set("Joel Hodgson", joel)

//----------------------------------------
// Example2 (composition)
//----------------------------------------

let creatorLens = Lens<Project, User>(
    get: { project in project.creator },
    set: { creator, project in Project(name: project.name, creator: creator, location: project.location) }
)

// dirty
p ===> creatorLens.set(
    nameLens.set(
        "Joel Hodgson",
        creatorLens.get(mst3k)
    ),
    mst3k
)

p ===> creatorLens // Lens<Project, User>
p ===> nameLens    // Lens<User, String>

/// Left-to-right composition, i.e. `>>>`.
func compose <A, B, C> (_ lhs: Lens<A, B>, _ rhs: Lens<B, C>) -> Lens<A, C> {
    return Lens<A, C>(
        get: { a in rhs.get(lhs.get(a)) },
        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}

let creatorNameLens = compose(creatorLens, nameLens)

p ===> creatorNameLens.get(mst3k)


func * <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return compose(lhs, rhs)
}

p ===> (creatorLens * nameLens).get(mst3k)
p ===> (creatorLens * nameLens).set("Joel Hodgson", mst3k)

//----------------------------------------
// Example3 (extension)
//----------------------------------------

extension Location {
    static let nameLens = Lens<Location, String>(
        get: { $0.name },
        set: { (name, _) in Location(name: name) }
    )
}

extension User {
    static let nameLens = Lens<User, String>(
        get: { $0.name },
        set: { (n, u) in User(name: n, location: u.location) }
    )
    static let locationLens = Lens<User, Location>(
        get: { $0.location },
        set: { (l, u) in User(name: u.name, location: l) }
    )
}
extension Project {
    static let nameLens = Lens<Project, String>(
        get: { $0.name },
        set: { (n, p) in Project(name: n, creator: p.creator, location: p.location) }
    )
    static let creatorLens = Lens<Project, User>(
        get: { $0.creator },
        set: { (c, p) in Project(name: p.name, creator: c, location: p.location) }
    )
    static let locationLens = Lens<Project, Location>(
        get: { $0.location },
        set: { (l, p) in Project(name: p.name, creator: p.creator, location: l) }
    )
}

p ===> (Project.creatorLens * User.locationLens * Location.nameLens).set("LA", mst3k)
//{Bring Back MYSTERY SCIENCE THEATER 3000, {Joel, {LA}}, {Minneapolis}}

//----------------------------------------
// Example4 (operators)
//----------------------------------------

precedencegroup ApplyPrecedence {
    associativity: left
    higherThan: ComparisonPrecedence
    lowerThan: MultiplicationPrecedence
}
precedencegroup LensSetPrecedence {
    associativity: left
    higherThan: ApplyPrecedence
    lowerThan: MultiplicationPrecedence
}
infix operator |> : ApplyPrecedence
infix operator *~ : LensSetPrecedence

/// replace-set
func *~ <A, B> (lhs: Lens<A, B>, rhs: B) -> (A) -> A {
    return { a in lhs.set(rhs, a) }
}

func |> <A, B> (x: A, f: (A) -> B) -> B {
    return f(x)
}

// same as `*` (less precedence)
func |> <A, B, C> (f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

p ===> (User.nameLens *~ "Joel Hodgson")(joel)

p ===> joel |> User.nameLens *~ "Joel Hodgson"

// composition
p ===> mst3k |> Project.locationLens * Location.nameLens *~ "LA"
    |> Project.creatorLens * User.nameLens *~ "Joel Hodgson"
    |> Project.creatorLens * User.locationLens * Location.nameLens *~ "New York"

//{Bring Back MYSTERY SCIENCE THEATER 3000, {Joel Hodgson, {New York}}, {LA}}

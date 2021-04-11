import PlaygroundSupport
import ComposableArchitecture

// MARK: Ergonomic State Management: Part 2 - Dynamic member lookup
struct User {
    var id: Int
    var name: String
    var bio: String
//    var isAdmin: Bool
}

@dynamicMemberLookup
struct Admin {
    var user: User

    subscript<A>(dynamicMember keyPath: KeyPath<User, A>) -> A {
        self.user[keyPath: keyPath]
    }
}

//let blob = User(id: 1, name: "Blob", bio: "Blobbed around the world", isAdmin: true)
//let blobJr = User(id: 2, name: "Blob Jr.", bio: "Blobbed around the world", isAdmin: false)
//
//func doAdminStuff(user: User) {
//    guard user.isAdmin else { return }
//    print("\(user.name) is an admin")
//}

let blob = Admin(user: User(id: 1, name: "Blob", bio: "Blobbed around the world"))
let blobJr = User(id: 2, name: "Blob Jr.", bio: "Blobbed around the world")

func doAdminStuff(user: Admin) {
    print("\(user.user.name) is an admin")
}

doAdminStuff(user: blob)
//doAdminStuff(user: blobJr)

blob.id
blob.name

class Thing  {
    var name:String
    init(name:String) {
        self.name = name
    }
}

extension Array where Element : Thing {
    func whereNamed(name:String) -> [Element] {
        return self.filter( { $0.name == name } )
    }
    
    mutating func appendDistinct(object : Generator.Element) {
        let filtered = self.filter( { $0.name == object.name } )
        if filtered.first == nil {
            self.append(object)
        }
    }
}

let thing1 = Thing(name: "Thing 1")
let thing2 = Thing(name: "Thing 2")
let thing3 = Thing(name: "Thing 3")
let thing4 = Thing(name: "Thing 3")

var things = [Thing]()
things.appendDistinct(thing1)
things.appendDistinct(thing2)
things.appendDistinct(thing3)
things.appendDistinct(thing4)

things.count

let found = things.whereNamed("Thing 3")

found.count



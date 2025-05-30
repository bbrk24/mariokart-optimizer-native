import Algorithms

func fourWayProduct<A: Collection, B: Collection, C: Collection, D: Collection>(
    _ first: A,
    _ second: B,
    _ third: C,
    _ fourth: D
) -> some Collection<(A.Element, B.Element, C.Element, D.Element)> {
    product(product(first, second), product(third, fourth)).lazy.map { ($0.0, $0.1, $1.0, $1.1) }
}

extension Sequence {
    consuming func maxAll(on callback: (Element) -> Float) -> [Element] {
        var maxValue = -Float.infinity
        var result = [Element]()
        for el in self {
            let currValue = callback(el)
            if currValue > maxValue {
                maxValue = currValue
                result = [el]
            } else if currValue == maxValue {
                result.append(el)
            }
        }
        return result
    }
}

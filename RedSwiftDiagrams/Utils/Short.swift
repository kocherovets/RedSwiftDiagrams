import Foundation

func run<T>(code: () -> T) -> T {
    return code()
}

func ui(closure: @escaping () -> ()) {
    let when = DispatchTime.now()
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func delay(_ delay: Double, closure: @escaping () -> ()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

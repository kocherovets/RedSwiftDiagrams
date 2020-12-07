import Foundation

func run<T>(code: () -> T) -> T {
    return code()
}

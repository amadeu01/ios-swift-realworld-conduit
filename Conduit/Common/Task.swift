import Foundation

public struct Task<T, E: Error> {
    public typealias Closure = (Controller<T, E>) -> Void

    private let closure: Closure

    public init(closure: @escaping Closure) {
        self.closure = closure
    }
}

extension Task {
    public struct Controller<T, E: Error> {
        fileprivate let queue: DispatchQueue
        fileprivate let handler: (Result<T, E>) -> Void

        public func finish(_ value: T) {
            handler(.success(value))
        }

        public func fail(with error: E) {
            handler(.failure(error))
        }

        public func resolve(_ result: Result<T, E>) {
            handler(result)
        }
    }
}

extension Task {
    public func perform(on queue: DispatchQueue = .global(),
                        then handler: @escaping (Result<T, E>) -> Void) {
        queue.async {
            let controller = Controller(
                queue: queue,
                handler: handler
            )

            self.closure(controller)
        }
    }
}

extension Task {
    public func flatMap<NewValue>(_ transform: @escaping (T) -> Result<NewValue, E> ) -> Task<NewValue, E> {
        return Task<NewValue, E> { controller in
            self.perform(on: controller.queue) { result in
                controller.resolve(result.flatMap(transform))
            }
        }
    }

    public func map<NewValue>(_ transform: @escaping (T) -> NewValue ) -> Task<NewValue, E> {
        return Task<NewValue, E> { controller in
            self.perform(on: controller.queue) { result in
                controller.resolve(result.map(transform))
            }
        }
    }
}

//swiftlint:disable identifier_name large_tuple type_name
public extension Task {
    static func zip<A, B>(
        _ t1: Task<A, E>,
        _ t2: Task<B, E>
        ) -> Task<(A, B), E> where E == Swift.Error {
        return Task<(A, B), E> { controller in
            t1.perform(on: controller.queue) { t1result in
                t2.perform(on: controller.queue) { t2result in
                    controller.resolve(
                        Result<(A, B), E>.zip(t1result, t2result)
                    )
                }
            }
        }
    }
}

public extension Result {
    static func zip<A, B>(
        _ r1: Result<A, Failure>,
        _ r2: Result<B, Failure>
        ) -> Result<(A, B), Failure>
        where Failure == Swift.Error {
            return Result<(A, B), Failure>.init { () -> (A, B) in
                let a = try r1.get()
                let b = try r2.get()
                return (a, b)
            }
    }
}
//swiftlint:enable identifier_name large_tuple type_name

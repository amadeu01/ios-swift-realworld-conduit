//
//  Operators.swift
//  RDServerKit
//
//  Created by Amadeu Cavalcante Filho on 26/02/19.
//  Copyright © 2019 Pixeon Medical Systems. All rights reserved.
//

import Foundation

//swiftlint:disable identifier_name redundant_void_return
precedencegroup ForwardApplication {
    associativity: left
}
infix operator |>: ForwardApplication
public func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}
public func |> <A: AnyObject>(x: A, f: (A) -> Void) -> Void {
    f(x)
}

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
}
infix operator >=>: EffectfulComposition
public func >=> <A, B, C>(
    _ f: @escaping (A) -> (B, [String]),
    _ g: @escaping (B) -> (C, [String])
    ) -> ((A) -> (C, [String])) {

    return { a in
        let (b, logs) = f(a)
        let (c, moreLogs) = g(b)
        return (c, logs + moreLogs)
    }
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: EffectfulComposition
}
infix operator >>>: ForwardComposition
public func >>> <A, B, C>(
    f: @escaping (A) -> B,
    g: @escaping (B) -> C
    ) -> ((A) -> C) {

    return { a in g(f(a)) }
}

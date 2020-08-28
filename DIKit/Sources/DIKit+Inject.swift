// DIKit+Inject.swift
//
// - Authors:
// Ben John
//
// - Date: 20.10.2019
//
// Copyright © 2019 Ben John. All rights reserved.

/// A property wrapper (SE-0258) to make a `Component` lazily injectable
/// through `@LazyInject var variableName: Component`.
@propertyWrapper
public final class LazyInject<Component> {
    
    private enum State<Component> {
        case unresolved(() -> Component)
        case resolved(Component)
    }
    
    public var wrappedValue: Component {
        switch state.value {
        case .resolved(let component):
            return component
        case .unresolved(let resolver):
            let component = resolver()
            state.mutate { $0 = .resolved(component) }
            return component
        }
    }
    
    private let state: Atomic<State<Component>>

    public init() {
        state = Atomic(.unresolved({ resolve() }))
    }

    public init(tag: AnyHashable? = nil) {
        state = Atomic(.unresolved({ resolve(tag: tag) }))
    }
}

/// A property wrapper (SE-0258) to make a `Component` eagerly injectable
/// through `@Inject var variableName: Component`.
@propertyWrapper
public struct Inject<Component> {
    public let wrappedValue: Component

    public init() {
        self.wrappedValue = resolve()
    }

    public init(tag: AnyHashable? = nil) {
        self.wrappedValue = resolve(tag: tag)
    }
}

/// A property wrapper (SE-0258) to make a `Optional<Component>` injectable
/// through `@OptionalInject var variableName: Component?`. Lazy by default.
@propertyWrapper
public final class OptionalInject<Component> {
    
    private enum State<Component> {
        case unresolved(() -> Component?)
        case resolved(Component?)
    }
    
    public var wrappedValue: Component? {
        switch state.value {
        case .resolved(let component):
            return component
        case .unresolved(let resolver):
            let component = resolver()
            state.mutate { $0 = .resolved(component) }
            return component
        }
    }
    
    private let state: Atomic<State<Component>>

    public init() {
        state = Atomic(.unresolved({ resolveOptional() }))
    }

    public init(tag: AnyHashable? = nil) {
        state = Atomic(.unresolved({ resolveOptional(tag: tag) }))
    }
}

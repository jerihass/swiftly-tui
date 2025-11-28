extension SwiftlyTUIApplication {
    mutating func pushCurrentScreen() {
        model.navigationStack.append(model.screen)
    }
}

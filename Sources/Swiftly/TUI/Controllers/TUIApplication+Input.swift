import Foundation
import SwifTeaUI

extension SwiftlyTUIApplication {
    func mapKeyToAction(_ key: KeyEvent) -> Action? {
        switch model.screen {
        case .menu, .result, .progress:
            switch key {
            case .char("1"):
                return .start(.list)
            case .char("2"):
                return .start(.install)
            case .char("3"):
                return .start(.uninstall)
            case .char("4"):
                return .start(.update)
            case .char("0"), .char("q"), .char("Q"):
                return .exit
            default:
                return nil
            }
        case .installList:
            switch key {
            case .upArrow, .char("k"):
                return .moveFocus(-1)
            case .downArrow, .char("j"):
                return .moveFocus(1)
            case .enter, .char(" "):
                return .installFocused
            case .char("/"):
                return .startFilter
            case .char(let ch) where model.isFiltering:
                return .filterChar(ch)
            case .backspace:
                return model.isFiltering ? .filterBackspace : nil
            case .escape:
                return (model.isFiltering || !model.filter.isEmpty) ? .clearFilter : nil
            case .char("m"), .char("M"):
                return .startManualInstall
            case .char("b"), .char("B"):
                return .back
            case .char("0"), .char("q"), .char("Q"):
                return .exit
            default:
                return nil
            }
        case .list:
            switch key {
            case .char(let ch) where ("0"..."9").contains(ch):
                guard !model.isFiltering else { return .filterChar(ch) }
                guard let idx = Int(String(ch)) else { return nil }
                if idx == 0 { return .exit }
                return .selectIndex(idx - 1)
            case .char("1"):
                return .start(.list) // refresh
            case .upArrow, .char("k"):
                return .moveFocus(-1)
            case .downArrow, .char("j"):
                return .moveFocus(1)
            case .enter, .char(" "):
                return .openFocused
            case .char("s"), .char("S"):
                return .switchFocused
            case .char("b"), .char("B"):
                return .back
            case .char("/"):
                return .startFilter
            case .char(let ch):
                if model.isFiltering { return .filterChar(ch) }
                return nil
            case .backspace:
                if model.isFiltering { return .filterBackspace }
                return nil
            case .escape:
                if model.isFiltering || !model.filter.isEmpty { return .clearFilter }
                return nil
            case .char("q"), .char("Q"):
                return .exit
            default:
                return nil
            }
        case .input:
            switch key {
            case .enter:
                return .submit
            case .backspace:
                return .backspace
            case .escape:
                return .cancelInput
            case .char(let ch):
                return .inputChar(ch)
            default:
                return nil
            }
        case .detail:
            switch key {
            case .char("s"), .char("S"):
                return .confirmSwitchFromDetail
            case .char("b"), .char("B"):
                return .back
            default:
                return nil
            }
        case .error:
            switch key {
            case .char("r"), .char("R"):
                return .retryLast
            case .char("c"), .char("C"):
                return .cancelRecovery
            case .char("b"), .char("B"):
                return .back
            case .char("q"), .char("Q"), .char("0"):
                return .exit
            default:
                return nil
            }
        }
    }

    func shouldExit(for action: Action) -> Bool {
        if case .exit = action { return true }
        return false
    }

    mutating func initializeEffects() {
        // Start in menu; no preloading.
    }

    mutating func handleTerminalResize(from _: TerminalSize, to _: TerminalSize) {}

    mutating func handleFrame(deltaTime: TimeInterval) {
        overlayPresenter.tick(deltaTime: deltaTime)
    }
}

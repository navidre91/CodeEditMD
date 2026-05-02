//
//  CETerminalView.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/11/25.
//

import SwiftTerm
import AppKit

/// # Please see dev note in ``CELocalShellTerminalView``!

private let terminalFollowScrollThreshold = 0.985
private let terminalScrollJumpLineLimit = 100_000

class CETerminalView: TerminalView {
    var performanceIdentifier: UUID?

    override func setFrameSize(_ newSize: NSSize) {
        if newSize != .zero {
            preservingScrollPositionIfNeeded {
                super.setFrameSize(newSize)
            }
        }
    }

    override open var frame: CGRect {
        get {
            super.frame
        }
        set {
            if newValue.size != .zero {
                preservingScrollPositionIfNeeded {
                    super.frame = newValue
                }
            }
        }
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()

        guard let performanceIdentifier else {
            return
        }

        if superview == nil {
            TerminalPerformanceLog.mark("terminal detached \(performanceIdentifier)")
        } else {
            TerminalPerformanceLog.mark("terminal attached \(performanceIdentifier)")
        }
    }

    var shouldFollowOutput: Bool {
        !canScroll || scrollPosition >= terminalFollowScrollThreshold
    }

    func preserveScrollPositionIfNeeded<T>(_ operation: () -> T) -> T {
        let shouldPreserve = !shouldFollowOutput
        let previousYDisplay = terminal.buffer.yDisp
        let result = operation()

        if shouldPreserve {
            restoreScrollPosition(previousYDisplay)
        } else {
            jumpToBottomIfNeeded()
        }

        return result
    }

    private func preservingScrollPositionIfNeeded(_ operation: () -> Void) {
        guard terminal != nil else {
            operation()
            return
        }

        let start = TerminalPerformanceLog.timestamp()
        preserveScrollPositionIfNeeded(operation)

        if let performanceIdentifier {
            TerminalPerformanceLog.duration("terminal resize \(performanceIdentifier)", from: start)
        }
    }

    private func restoreScrollPosition(_ previousYDisplay: Int) {
        let delta = terminal.buffer.yDisp - previousYDisplay

        if delta > 0 {
            scrollUp(lines: delta)
        } else if delta < 0 {
            scrollDown(lines: -delta)
        }
    }

    private func jumpToBottomIfNeeded() {
        guard canScroll, scrollPosition < 1 else {
            return
        }

        scrollDown(lines: terminalScrollJumpLineLimit)
    }

    @objc
    override open func copy(_ sender: Any) {
        let range = selectedPositions()
        let text = terminal.getText(start: range.start, end: range.end)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    override open func isAccessibilityElement() -> Bool {
        true
    }

    override open func isAccessibilityEnabled() -> Bool {
        true
    }

    override open func accessibilityLabel() -> String? {
        "Terminal Emulator"
    }

    override open func accessibilityRole() -> NSAccessibility.Role? {
        .textArea
    }

    override open func accessibilityValue() -> Any? {
        terminal.getText(
            start: Position(col: 0, row: 0),
            end: Position(col: terminal.buffer.x, row: terminal.getTopVisibleRow() + terminal.rows)
        )
    }

    override open func accessibilitySelectedText() -> String? {
        let range = selectedPositions()
        let text = terminal.getText(start: range.start, end: range.end)
        return text
    }

}

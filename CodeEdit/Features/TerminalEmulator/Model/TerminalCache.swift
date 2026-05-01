//
//  TerminalCache.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/27/24.
//

import Foundation
import SwiftTerm

/// Stores a mapping of ID -> terminal view for reusing terminal views.
/// This allows terminal views to continue to receive data even when not in the view hierarchy.
final class TerminalCache {
    static let shared: TerminalCache = TerminalCache()

    /// The cache of terminal views.
    private var terminals: [UUID: CELocalShellTerminalView]

    /// The terminal style signature applied to each cached view.
    private var configurationSignatures: [UUID: String]

    private init() {
        terminals = [:]
        configurationSignatures = [:]
    }

    /// Get a cached terminal view.
    /// - Parameter id: The ID of the terminal.
    /// - Returns: The existing terminal, if it exists.
    func getTerminalView(_ id: UUID) -> CELocalShellTerminalView? {
        terminals[id]
    }

    /// Store a terminal view for reuse.
    /// - Parameters:
    ///   - id: The ID of the terminal.
    ///   - view: The view representing the terminal's contents.
    func cacheTerminalView(for id: UUID, view: CELocalShellTerminalView) {
        terminals[id] = view
    }

    /// Get the last terminal style signature applied to a cached view.
    /// - Parameter id: The ID of the terminal.
    /// - Returns: The style signature, if one was cached.
    func getConfigurationSignature(_ id: UUID) -> String? {
        configurationSignatures[id]
    }

    /// Store the terminal style signature applied to a cached view.
    /// - Parameters:
    ///   - signature: The applied style signature.
    ///   - id: The ID of the terminal.
    func cacheConfigurationSignature(_ signature: String, for id: UUID) {
        configurationSignatures[id] = signature
    }

    /// Remove any view associated with the terminal id.
    /// - Parameter id: The ID of the terminal.
    func removeCachedView(_ id: UUID) {
        terminals[id] = nil
        configurationSignatures[id] = nil
    }
}

//
//  AlertManager.swift
//  wordle-clone
//
//  Created by Stephan Büeler on 06.12.2025.
//

import SwiftUI

class AlertManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    
    private var alertDismissalTask: DispatchWorkItem?
    
    func showAlertMessage(_ msg: String, _ duration: Double = 1.5) {
        alertDismissalTask?.cancel()
        message = msg
        withAnimation(.spring()) { isShowing = true }
        let task = DispatchWorkItem {
            withAnimation(.easeOut) { self.isShowing = false }
        }
        alertDismissalTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
    
    func dismiss() {
        alertDismissalTask?.cancel()
        withAnimation(.easeOut) { isShowing = false }
    }
}

// MARK: - View Extension

extension View {
    /// Attaches an alert overlay to any view
    /// - Parameter alertManager: The alert manager to observe
    /// - Returns: View with alert overlay
    func alertOverlay(_ alertManager: AlertManager) -> some View {
        self.overlay(
            Group {
                if alertManager.isShowing {
                    Text(alertManager.message)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }, alignment: .top
        )
    }
}

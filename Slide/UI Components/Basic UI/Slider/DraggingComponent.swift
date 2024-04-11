//  DraggingComponent.swift
//  Slide
//  Created by Ethan Harianto on 8/14/23.

import CoreHaptics
import SwiftUI

struct DraggingComponent: View {
    @Binding var isRSVPed: Bool
    let isLoading: Bool
    let maxWidth: CGFloat

    @State private var width = CGFloat(50)
    private let minWidth = CGFloat(50)

    public init(isRSVPed: Binding<Bool>, isLoading: Bool, maxWidth: CGFloat) {
        _isRSVPed = isRSVPed
        self.isLoading = isLoading
        self.maxWidth = maxWidth
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.accentColor)
            .opacity(width / maxWidth)
            .frame(width: width)
            .overlay(
                Button(action: {
                    guard isRSVPed else { return }
                    withAnimation {
                        isRSVPed = false
                        width = minWidth
                    }
                }) {
                    ZStack {
                        image(name: "icon", isShown: !isRSVPed)
                        progressView(isShown: isLoading)
                        if isRSVPed && !isLoading {
                            Image(systemName: "xmark")
                        }
                    }
                    .animation(.easeIn(duration: 0.35).delay(0.55), value: isRSVPed && !isLoading)
                }
                .buttonStyle(BaseButtonStyle())
                .disabled(!isRSVPed || isLoading),
                alignment: .trailing
            )
            .onAppear {
                if isRSVPed {
                    width = maxWidth
                }
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard !isRSVPed else { return }
                        if value.translation.width > 0 {
                            width = min(max(value.translation.width + minWidth, minWidth), maxWidth)
                        }
                    }
                    .onEnded { _ in
                        guard !isRSVPed else { return }
                        if width < (maxWidth * 0.55) {
                            width = minWidth
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            withAnimation {
                                width = maxWidth
                            }
                            withAnimation(.spring().delay(0.5)) {
                                isRSVPed = true
                            }
                        }
                    }
            )
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 0), value: width)
    }

    private func image(name: String, isShown: Bool) -> some View {
        Image(name)
            .resizable()
            .frame(width: 42, height: 42)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.darkGray))
            .padding(4)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }

    private func progressView(isShown: Bool) -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.white)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }
}

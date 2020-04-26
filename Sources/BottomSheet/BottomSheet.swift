//
//  BottomSheet.swift
//  BottomSheet
//
//  Created by Tieda Wei on 2020-04-25.
//  Copyright © 2020 Tieda Wei. All rights reserved.
//

import SwiftUI

public struct BottomSheet<Content: View>: View {
    
    private var dragToDismissThreshold: CGFloat { maxHeight * 0.4 }
    private var grayBackgroundOpacity: Double { shouldShow ? (0.4 - Double(draggedOffset)/600) : 0 }
    private let dragUpOffset: CGFloat = -30
    private let topBarHeight: CGFloat = 30
    
    @State private var draggedOffset: CGFloat = 0
    @State private var previousDragValue: DragGesture.Value?

    @Binding var shouldShow: Bool
    let maxHeight: CGFloat
    private let content: Content
    
    let contentBackgroundColor: Color
    let topBarBackgroundColor: Color
    
    public init(
        shouldShow: Binding<Bool>,
        maxHeight: CGFloat,
        topBarBackgroundColor: Color = Color(.systemBackground),
        contentBackgroundColor: Color = Color(.systemBackground),
        @ViewBuilder content: () -> Content
    ) {
        self.topBarBackgroundColor = topBarBackgroundColor
        self.contentBackgroundColor = contentBackgroundColor
        self._shouldShow = shouldShow
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.fullScreenLightGrayOverlay()
                VStack(spacing: 0) {
                    self.topBar(geometry: geometry)
                    VStack {
                        self.content.padding(.bottom, geometry.safeAreaInsets.bottom)
                    }
                }
                .frame(height: self.maxHeight)
                .background(self.contentBackgroundColor)
                .cornerRadius(self.topBarHeight/3, corners: [.topLeft, .topRight])
                .animation(.interactiveSpring())
                .offset(y: self.shouldShow ? (geometry.size.height/2 - self.maxHeight/2 + geometry.safeAreaInsets.bottom + self.draggedOffset) : (geometry.size.height/2 + self.maxHeight/2 + geometry.safeAreaInsets.bottom))
            }
        }
    }
    
    fileprivate func fullScreenLightGrayOverlay() -> some View {
        Color
            .black
            .opacity(grayBackgroundOpacity)
            .edgesIgnoringSafeArea(.all)
            .animation(.interactiveSpring())
            .onTapGesture { self.shouldShow = false }
    }
    
    fileprivate func topBar(geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary)
                .frame(width: 40, height: 6)
        }
        .frame(width: geometry.size.width, height: self.topBarHeight)
        .background(topBarBackgroundColor)
        .gesture(
            DragGesture()
                .onChanged({ (value) in
                    
                    let offsetY = value.translation.height
                    guard offsetY >= self.dragUpOffset else { return }
                    
                    if let previousValue = self.previousDragValue {
                        let previousOffsetY = previousValue.translation.height
                        let timeDiff = Double(value.time.timeIntervalSince(previousValue.time))
                        let heightDiff = Double(offsetY - previousOffsetY)
                        let velocityY = heightDiff / timeDiff
                        if velocityY > 1400 {
                            self.shouldShow = false
                            return
                        }
                    }
                    self.previousDragValue = value
                    
                    self.draggedOffset = offsetY
                })
                .onEnded({ (value) in
                    let offsetY = value.translation.height
                    if offsetY > self.dragToDismissThreshold {
                        self.shouldShow = false
                    }
                    self.draggedOffset = 0
                })
        )
    }
}

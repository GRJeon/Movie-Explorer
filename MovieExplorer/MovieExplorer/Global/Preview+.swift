//
//  Preview+.swift
//  MovieExplorer
//
//  Created by Liam on 5/3/26.
//

#if DEBUG
import SwiftUI

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View

    init(_ builder: @escaping () -> View) {
        self.view = builder()
    }

    func makeUIView(context: Context) -> UIView {
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif

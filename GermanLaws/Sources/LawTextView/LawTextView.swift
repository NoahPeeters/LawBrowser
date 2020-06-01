//
//  File.swift
//  
//
//  Created by Noah Peeters on 31.05.20.
//

import Foundation
import SwiftUI
import UIKit
import GermanLaws

public struct LawTextView: UIViewRepresentable {
    public let lawText: String

    public init(lawText: String) {
        self.lawText = lawText
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }

    public func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = attributedText

        textView.textColor = .label
//        textView.font = UIFont.preferredFont(forTextStyle: .body)
    }

    var attributedText: NSAttributedString? {
        guard let mutableText = try? NSMutableAttributedString(data: Data(lawText.utf8),
                                                               options: [
                                                                   .documentType: NSAttributedString.DocumentType.rtf,
                                                                   .characterEncoding: String.Encoding.utf8.rawValue
                                                               ],
                                                               documentAttributes: nil) else {
            return nil
        }

        mutableText.beginEditing()

        let textRange = NSRange(location: 0, length: mutableText.length)
        mutableText.enumerateAttribute(.font, in: textRange, options: []) { font, range, _ in
            guard let font = font as? UIFont else { return }
            let newFont = font.withSize(font.pointSize * 1.5)

            mutableText.removeAttribute(.font, range: range)
            mutableText.addAttribute(.font, value: newFont, range: range)
        }

        mutableText.endEditing()
        return mutableText
    }
}

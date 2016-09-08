//
//  ZZTagsField.swift
//  DailyNotes
//
//  Created by Zhicong Zang on 9/8/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

@IBDesignable
class ZZTagsField: UIView {
    
    private static let HSpace: CGFloat = 0.0
    private static let TextFieldHSpace: CGFloat = ZZTagView.XPadding
    private static let VSpace: CGFloat = 4.0
    private static let MinTextFieldWidth: CGFloat = 56.0
    private static let RowHeight: CGFloat = 25.0
    private static let FieldMarginX: CGFloat = ZZTagView.XPadding
    
    private let textField = BackspaceDetectingTextField()
    
    @IBInspectable override var tintColor: UIColor! {
        didSet {
            tagViews.forEach() { item in
                item.tintColor = self.tintColor
            }
        }
    }
    
    @IBInspectable var textColor: UIColor? {
        didSet {
            tagViews.forEach() { item in
                item.textColor = self.textColor
            }
        }
    }
    
    @IBInspectable var selectedColor: UIColor? {
        didSet {
            tagViews.forEach() { item in
                item.selectedColor = self.selectedColor
            }
        }
    }
    
    @IBInspectable var selectedTextColor: UIColor? {
        didSet {
            tagViews.forEach() { item in
                item.selectedTextColor = self.selectedTextColor
            }
        }
    }
    
    @IBInspectable var fieldTextColor: UIColor? {
        didSet {
            textField.textColor = textColor
        }
    }
    
    @IBInspectable var placeholder: String = "Tags" {
        didSet {
            updatePlaceholderTextVisibility()
        }
    }
    
    @IBInspectable var font: UIFont? {
        didSet {
            textField.font = font
            tagViews.forEach() { item in
                item.font = self.font
            }
        }
    }
    
    @IBInspectable var readOnly: Bool = false {
        didSet {
            unselectAllTagViews()
            textField.enabled = !readOnly
            repositionViews()
        }
    }
    
    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 8.0, bottom: 10.0, right: 8.0) {
        didSet {
            repositionViews()
        }
    }
    
    @IBInspectable var spaceBetweenTags: CGFloat = 2.0 {
        didSet {
            repositionViews()
        }
    }
    
    @IBInspectable var keyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        
        set {
            textField.keyboardType = newValue
        }
    }
    
    private(set) var tags = [ZZTag]()
    private var tagViews = [ZZTagView]()
    private var intrinsicContentHeight: CGFloat = 0.0
    
    var onDidEndEditing: ((ZZTagsField) -> Void)?
    
    var onDidBeginEditing: ((ZZTagsField) -> Void)?
    
    var onShouldReturn: ((ZZTagsField) -> Bool)?
    
    var onDidChangeText: ((ZZTagsField, text: String?) -> Void)?
    
    var onDidAddTag: ((ZZTagsField, tag: ZZTag) -> Void)?
    
    var onDidRemoveTag: ((ZZTagsField, tag: ZZTag) -> Void)?
    
    var onVerifyTag: ((ZZTagsField, text: String) -> Bool)?
    
    var onDidChangeHeightTo: ((ZZTagsField, height: CGFloat) -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        textColor = .whiteColor()
        selectedColor = .grayColor()
        selectedTextColor = .blackColor()
        
        textField.backgroundColor = .clearColor()
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.autocapitalizationType = UITextAutocapitalizationType.None
        textField.delegate = self
        textField.font = font
        textField.textColor = fieldTextColor
        addSubview(textField)
        
        textField.onDeleteBackwards = {
            if self.readOnly {
                return
            }
            if self.textField.text?.isEmpty ?? true, let tagView = self.tagViews.last {
                self.selectTagView(tagView, animated: true)
                self.textField.resignFirstResponder()
            }
        }
        
        textField.addTarget(self, action: #selector(onTextFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        intrinsicContentHeight = ZZTagsField.RowHeight
        repositionViews()
    }
    
    private func repositionViews() {
        let rightBoundary: CGFloat = CGRectGetWidth(self.bounds) - padding.right
        let firstLineRightBoundary: CGFloat = rightBoundary
        var curX: CGFloat = padding.left
        var curY: CGFloat = padding.top
        var totalHeight: CGFloat = ZZTagsField.RowHeight
        var isOnFirstLine = true
        
        // Position Tag views
        var tagRect = CGRect.null
        for tagView in tagViews {
            tagRect = CGRect(origin: CGPoint.zero, size: tagView.sizeToFit(self.intrinsicContentSize()))
            
            let tagBoundary = isOnFirstLine ? firstLineRightBoundary : rightBoundary
            if curX + CGRectGetWidth(tagRect) > tagBoundary {
                // Need a new line
                curX = padding.left
                curY += ZZTagsField.RowHeight + ZZTagsField.VSpace
                totalHeight += ZZTagsField.RowHeight
                isOnFirstLine = false
            }
            
            tagRect.origin.x = curX
            // Center our tagView vertically within STANDARD_ROW_HEIGHT
            tagRect.origin.y = curY + ((ZZTagsField.RowHeight - CGRectGetHeight(tagRect))/2.0)
            tagView.frame = tagRect
            tagView.setNeedsLayout()
            
            curX = CGRectGetMaxX(tagRect) + ZZTagsField.HSpace + self.spaceBetweenTags
        }
        
        // Always indent TextField by a little bit
        curX += max(0, ZZTagsField.TextFieldHSpace - self.spaceBetweenTags)
        let textBoundary: CGFloat = isOnFirstLine ? firstLineRightBoundary : rightBoundary
        var availableWidthForTextField: CGFloat = textBoundary - curX
        if availableWidthForTextField < ZZTagsField.MinTextFieldWidth {
            isOnFirstLine = false
            // If in the future we add more UI elements below the tags,
            // isOnFirstLine will be useful, and this calculation is important.
            // So leaving it set here, and marking the warning to ignore it
            curX = padding.left + ZZTagsField.TextFieldHSpace
            curY += ZZTagsField.RowHeight + ZZTagsField.VSpace
            totalHeight += ZZTagsField.RowHeight
            // Adjust the width
            availableWidthForTextField = rightBoundary - curX
        }
        
        var textFieldRect: CGRect
        if textField.enabled {
            textFieldRect = self.textField.frame
            textFieldRect.origin.x = curX
            textFieldRect.origin.y = curY
            textFieldRect.size.width = availableWidthForTextField
            textFieldRect.size.height = ZZTagsField.RowHeight
        }
        else {
            textFieldRect = CGRect.zero
            textField.hidden = true
        }
        self.textField.frame = textFieldRect
        
        let oldContentHeight: CGFloat = self.intrinsicContentHeight
        intrinsicContentHeight = max(totalHeight, CGRectGetMaxY(textFieldRect) + padding.bottom)
        invalidateIntrinsicContentSize()
        
        if oldContentHeight != self.intrinsicContentHeight {
            let newContentHeight = intrinsicContentSize().height
            if let didChangeHeightToEvent = self.onDidChangeHeightTo {
                didChangeHeightToEvent(self, height: newContentHeight)
            }
            frame.size.height = newContentHeight
        }
        else {
            frame.size.height = oldContentHeight
        }
        setNeedsDisplay()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: self.frame.size.width - padding.left - padding.right, height: max(45, self.intrinsicContentHeight))
    }
    
    private func updatePlaceholderTextVisibility() {
        if tags.count > 0 {
            textField.placeholder = nil
        }
        else {
            textField.placeholder = self.placeholder
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tagViews.forEach {
            $0.setNeedsLayout()
        }
        repositionViews()
    }
    
    func acceptCurrentTextAsTag() {
        if let currentText = tokenizeTextFieldText() where (self.textField.text?.isEmpty ?? true) == false {
            self.addTag(currentText)
        }
    }
    
    var isEditing: Bool {
        return self.textField.editing
    }
    
    func beginEditing() {
        self.textField.becomeFirstResponder()
        self.unselectAllTagViews()
    }
    
    func endEditing() {
        self.textField.resignFirstResponder()
    }
    
    func addTags(tags: [String]) {
        tags.forEach() { addTag($0) }
    }
    
    func addTags(tags: [ZZTag]) {
        tags.forEach() { addTag($0) }
    }
    
    func addTag(tag: String) {
        addTag(ZZTag(text: tag))
    }
    
    func addTag(tag: ZZTag) {
        if self.tags.contains(tag) {
            return
        }
        self.tags.append(tag)
        
        let tagView = ZZTagView(tag: tag)
        tagView.font = self.font
        tagView.tintColor = self.tintColor
        tagView.textColor = self.textColor
        tagView.selectedColor = self.selectedColor
        tagView.selectedTextColor = self.selectedTextColor
        
        tagView.onDidRequestSelection = { tagView in
            self.selectTagView(tagView, animated: true)
        }
        
        tagView.onDidRequestDelete  = { tagView, replacementText in
            self.textField.becomeFirstResponder()
            if !(replacementText?.isEmpty ?? true) {
                self.textField.text = replacementText
            }
            if let index = self.tagViews.indexOf(tagView) {
                self.removeTagAtIndex(index)
            }
        }
        
        self.tagViews.append(tagView)
        addSubview(tagView)
        
        self.textField.text = ""
        if let didAddTagEvent = onDidAddTag {
            didAddTagEvent(self, tag: tag)
        }
        
        onTextFieldDidChange(self.textField)
        repositionViews()
    }
    
    func removeTag(tag: String) {
        removeTag(ZZTag(text: tag))
    }
    
    func removeTag(tag: ZZTag) {
        if let index = self.tags.indexOf(tag) {
            removeTagAtIndex(index)
        }
    }
    
    func removeTagAtIndex(index: Int) {
        if index >= 0 && index < self.tagViews.count {
            let tagView = self.tagViews[index]
            tagView.removeFromSuperview()
            self.tagViews.removeAtIndex(index)
            let removedTag = self.tags[index]
            self.tags.removeAtIndex(index)
            if let didRemoveTagEvent = onDidRemoveTag {
                didRemoveTagEvent(self, tag: removedTag)
            }
            updatePlaceholderTextVisibility()
            repositionViews()
        }
    }
    
    func removeTags() {
        self.tags.enumerate().reverse().forEach { (index, _) in
            removeTagAtIndex(index)
        }
    }
    
    func onTextFieldDidChange(sender: AnyObject) {
        if let didChangeTextEvent = onDidChangeText {
            didChangeTextEvent(self, text: textField.text)
        }
    }
    
    func tokenizeTextFieldText() -> ZZTag? {
        let text = self.textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) ?? ""
        if !text.isEmpty && (onVerifyTag?(self, text: text) ?? true) {
            let tag = ZZTag(text: text)
            addTag(tag)
            self.textField.text = ""
            onTextFieldDidChange(self.textField)
            return tag
        }
        return nil
    }
    
    func selectTagView(tagView: ZZTagView, animated: Bool = false) {
        if readOnly {
            return
        }
        tagView.selected = true
        tagViews.forEach { (view) in
            if view != tagView {
                view.selected = false
            }
        }
    }
    
    func unselectAllTagViews(animated animated: Bool = false) {
        tagViews.forEach() { item in
            item.selected = false
        }
    }
    
}

extension ZZTagsField: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        if let didBeginEditingEvent = onDidBeginEditing {
            didBeginEditingEvent(self)
        }
        unselectAllTagViews()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let didEndEditingEvent = onDidEndEditing {
            didEndEditingEvent(self)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        tokenizeTextFieldText()
        var shouldDoDefaultBehavior = false
        if let shouldReturnEvent = onShouldReturn {
            shouldDoDefaultBehavior = shouldReturnEvent(self)
        }
        return shouldDoDefaultBehavior
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}




private class BackspaceDetectingTextField: UITextField {
    
    var onDeleteBackwards: (() -> ())?
    
    init() {
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        if let deleteBackwardsEvent = onDeleteBackwards {
            deleteBackwardsEvent()
        }
        super.deleteBackward()
    }
    
    
}

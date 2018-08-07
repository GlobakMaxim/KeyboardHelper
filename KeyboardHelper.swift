import UIKit

protocol KeyboardHelperDelegate: class {
  func updateKeyboard(size: CGSize, action: KeyboardHelper.Action, duration: TimeInterval)
}

class KeyboardHelper {

  enum Action {
    case willShow
    case didShow
    case willHide
    case didHide
    case didChangeFrame
  }

  weak var delegate: KeyboardHelperDelegate?
  private var isOpenKeyboard: Bool = false

  func startObserve() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(_:)),
                                           name: .UIKeyboardWillShow,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidShow(_:)),
                                           name: .UIKeyboardDidShow,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(_:)),
                                           name: .UIKeyboardWillHide,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidHide(_:)),
                                           name: .UIKeyboardDidHide,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidChangeFrame(_:)),
                                           name: .UIKeyboardDidChangeFrame,
                                           object: nil)
  }

  func stopObserve() {
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidChangeFrame, object: nil)
  }

  // MARK: - Keyboard Handling
  @objc private func keyboardWillShow(_ notification: Notification) {
    let keyboardSize = findKeyboardSize(from: notification)
    let animationDuration = findAimationDuration(from: notification)
    delegate?.updateKeyboard(size: keyboardSize, action: .willShow, duration: animationDuration)
  }

  @objc private func keyboardDidShow(_ notification: Notification) {
    isOpenKeyboard = true
  }

  @objc private func keyboardWillHide(_ notification: Notification) {
    isOpenKeyboard = false
    let keyboardSize = CGSize.zero
    let animationDuration = findAimationDuration(from: notification)
    delegate?.updateKeyboard(size: keyboardSize, action: .willHide, duration: animationDuration)
  }

  @objc private func keyboardDidHide(_ notification: Notification) {
  }

  @objc private func keyboardDidChangeFrame(_ notification: Notification) {
    guard isOpenKeyboard else { return }
    let keyboardSize = findKeyboardSize(from: notification)
    let animationDuration = findAimationDuration(from: notification)
    delegate?.updateKeyboard(size: keyboardSize, action: .didChangeFrame, duration: animationDuration)
  }

  // MARK: - Support functions
  private func findKeyboardSize(from notification: Notification) -> CGSize {
    guard let userInfo = notification.userInfo else { return CGSize.zero }
    guard let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return CGSize.zero }
    return  keyboardFrame.size
  }

  private func findAimationDuration(from notification: Notification) -> TimeInterval {
    let defaultValue = 0.25 as TimeInterval
    guard let userInfo = notification.userInfo else { return defaultValue }
    return userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? defaultValue
  }

}

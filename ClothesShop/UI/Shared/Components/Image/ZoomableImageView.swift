import SwiftUI
import UIKit
import AVFoundation

/// Картинка с масштабированием на `UIScrollView`, как в «Фото».
///
/// SwiftUI не умеет масштабировать `ScrollView`, поэтому используется `UIScrollView` — так рекомендует Apple:
/// щипок увеличивает от точки между пальцами, двойной тап — к месту тапа (повторный возвращает обратно),
/// у перемещения есть инерция, у краёв и пределов масштаба — пружинящий отскок.
/// Без увеличения свайп вниз уводит картинку за пальцем и закрывает экран.
struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    var accessibilityLabel: String = ""
    /// Сдвиг картинки вниз при закрытии свайпом: по нему экран затемняет фон и прячет кнопки.
    var onDismissDrag: (CGFloat) -> Void = { _ in }
    var onDismiss: () -> Void = {}

    func makeUIView(context: Context) -> ZoomingScrollView {
        ZoomingScrollView(image: image)
    }

    func updateUIView(_ view: ZoomingScrollView, context: Context) {
        view.setImage(image)
        view.imageView.accessibilityLabel = accessibilityLabel
        view.onDismissDrag = onDismissDrag
        view.onDismiss = onDismiss
    }
}

final class ZoomingScrollView: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    private typealias Constants = ComponentConstants.FullScreenImage

    let imageView = UIImageView()
    var onDismissDrag: (CGFloat) -> Void = { _ in }
    var onDismiss: () -> Void = {}

    private var isZoomed: Bool { zoomScale > minimumZoomScale + 0.01 }

    init(image: UIImage) {
        super.init(frame: .zero)
        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = Constants.maxScale
        bouncesZoom = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        decelerationRate = .fast
        backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = .image
        imageView.image = image
        addSubview(imageView)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)

        let dismissPan = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan))
        dismissPan.maximumNumberOfTouches = 1
        dismissPan.delegate = self
        addGestureRecognizer(dismissPan)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setImage(_ image: UIImage) {
        guard imageView.image !== image else { return }
        imageView.image = image
        setZoomScale(minimumZoomScale, animated: false)
        layoutImage()
    }

    private var lastBoundsSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        // При смене размера (поворот, первый показ) картинка заново вписывается в экран.
        guard bounds.size != lastBoundsSize else { return }
        lastBoundsSize = bounds.size
        setZoomScale(minimumZoomScale, animated: false)
        layoutImage()
    }

    /// Вписывает картинку в экран при масштабе 1 с сохранением пропорций.
    private func layoutImage() {
        guard let size = imageView.image?.size, size.width > 0, size.height > 0 else { return }
        imageView.frame = AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: bounds.size))
        imageView.frame.origin = .zero
        contentSize = imageView.frame.size
        centerImage()
    }

    /// Пока картинка меньше экрана, держит её по центру.
    private func centerImage() {
        let horizontal = max(0, (bounds.width - contentSize.width) / 2)
        let vertical = max(0, (bounds.height - contentSize.height) / 2)
        contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImage() }

    // MARK: - Двойной тап

    /// Увеличивает к месту тапа; если уже увеличено — возвращает к исходному виду.
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if isZoomed {
            setZoomScale(minimumZoomScale, animated: true)
            return
        }
        let point = recognizer.location(in: imageView)
        let scale = min(Constants.doubleTapScale, maximumZoomScale)
        let size = CGSize(width: bounds.width / scale, height: bounds.height / scale)
        let rect = CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2,
                          width: size.width, height: size.height)
        zoom(to: rect, animated: true)
    }

    // MARK: - Закрытие свайпом вниз

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer, pan !== panGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        // Только без увеличения и только движение вниз: остальное — обычная прокрутка картинки.
        let velocity = pan.velocity(in: self)
        return !isZoomed && velocity.y > abs(velocity.x)
    }

    /// Свайп закрытия работает вместе с прокруткой: без увеличения ей всё равно нечего прокручивать.
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        otherGestureRecognizer === panGestureRecognizer
    }

    @objc private func handleDismissPan(_ recognizer: UIPanGestureRecognizer) {
        let translation = max(recognizer.translation(in: self).y, 0)
        switch recognizer.state {
        case .changed:
            imageView.transform = CGAffineTransform(translationX: 0, y: translation)
            onDismissDrag(translation)
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: self).y
            if translation > Constants.dismissDistance || velocity > Constants.dismissVelocity {
                onDismiss()
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0) {
                    self.imageView.transform = .identity
                }
                onDismissDrag(0)
            }
        default:
            break
        }
    }
}

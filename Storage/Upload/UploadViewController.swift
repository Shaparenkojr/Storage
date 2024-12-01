
import UIKit
import Combine

class MediaUploadViewController: UIViewController {
    
    private enum Constants {
        static let errorTitle = "Ошибка"
        static let messageTitle = "Sucsess"
        static let okButtonTitle = "Ок"
    }
    
    private lazy var mediaUploadView: MediaUploadView = {
        let view = MediaUploadView(frame: .zero, viewModel: viewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageListViewModel: ImagesListViewModel
    private let viewModel: MediaUploadViewModel
    private let imagePicker = UIImagePickerController()
    private var subscriptions: Set<AnyCancellable> = []
    private var uploadingImageUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupBindings()
    }
    
    init(viewModel: MediaUploadViewModel, imagesListViewModel: ImagesListViewModel) {
        self.viewModel = viewModel
        self.imageListViewModel = imagesListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MediaUploadViewController: MediaUploadViewDelegate {
    
    func showImagePicker() {
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func setImageURLFromGallery(_ url: String) {
        uploadingImageUrl = url
    }
}

extension MediaUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.mediaUploadView.setImageFromGallery(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

private extension MediaUploadViewController {
    
    func setupBindings() {
        viewModel.$imageData
            .sink { [weak self] imageData in
                if let imageData {
                    if let image = imageData.0 {
                        self?.mediaUploadView.setReadyState()
                        self?.mediaUploadView.setImage(with: image, for: imageData.1)
                        self?.uploadingImageUrl = imageData.1
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$processState
            .sink { [weak self] processState in
                switch processState {
                case .idle:
                    self?.mediaUploadView.setIdleState()
                case .loading:
                    self?.mediaUploadView.setLoadingState(for: .loadingFromNet)
                case .optimizing:
                    self?.mediaUploadView.setLoadingState(for: .optimizingImage)
                case .ready:
                    self?.mediaUploadView.setReadyState()
                case .uploadingOnServer:
                    self?.mediaUploadView.setLoadingState(for: .uploadingOnServer)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$requestError
            .sink { [weak self] error in
                if !error.isEmpty {
                    self?.showAlert(forMessage: error,
                                    withTitle: Constants.errorTitle)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$requestResultMessage
            .sink { [weak self] message in
                if !message.isEmpty {
                    self?.showAlert(forMessage: message,
                                    withTitle: Constants.messageTitle)
                }
            }
            .store(in: &subscriptions)
        
    }
    
    func showAlert(forMessage errorMessage: String, withTitle title: String) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        let okButton = UIAlertAction(title: Constants.okButtonTitle, style: .default,
                                     handler: { [weak self] _ in
            if let url = self?.uploadingImageUrl, !url.isEmpty {
                self?.imageListViewModel.addNewImageURL(url)
                self?.popToPreviousController()
            } else {
                self?.popToPreviousController()
            }
        })
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    func popToPreviousController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupController() {
        view.backgroundColor = .white
        view.addSubview(mediaUploadView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            mediaUploadView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mediaUploadView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mediaUploadView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mediaUploadView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

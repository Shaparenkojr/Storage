
import UIKit
import Combine

class MediaUploadViewController: UIViewController {

    
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
//        setupBindings()
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

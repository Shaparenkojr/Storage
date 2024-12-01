import UIKit

class ImagesListView: UIView {
    
    private enum Constants {
        static let showNextScreenButtonTitle = "Добавить изображение на сервер"
    }
    
    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.identifier)
        collectionView.backgroundColor = .systemGray6
        return collectionView
    }()
    
    private lazy var showNextScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.showNextScreenButtonTitle, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
        button.backgroundColor = .systemBlue 
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(showNextControllerButtonHandler),
                         for: .touchUpInside)
        return button
    }()
    
    private let viewModel: ImagesListViewModel
    private let imageCellViewModel: ImageCellViewModel
    private var images: [ImagesListModel]?
    
    init(frame: CGRect, viewModel: ImagesListViewModel, imageCellViewModel: ImageCellViewModel) {
        self.viewModel = viewModel
        self.imageCellViewModel = imageCellViewModel
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getImagesSize(imagesData: [ImagesListModel]) {
        images = imagesData
        imagesCollectionView.reloadData()
    }
}

extension ImagesListView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let imagesSize = images else { return 0 }
        return imagesSize.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.identifier, for: indexPath) as? ImageCollectionCell,
        let imagesModel = images else {
            return UICollectionViewCell()
        }
        let imageUrl = imagesModel[indexPath.item].url
        cell.viewModel = imageCellViewModel
        cell.backgroundColor = .white 
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        if let cachedImage = Memory.shared.getImageFromMemory(for: imageUrl) {
            cell.configureForCachedImage(cachedImage, imageUrl)
        } else {
            cell.configure(imageUrl)
        }
        return cell
    }
}

private extension ImagesListView {
    
    @objc
    func showNextControllerButtonHandler() {
        viewModel.buttonDidTapped()
    }
    
    func setupView() {
        addSubview(imagesCollectionView)
        addSubview(showNextScreenButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imagesCollectionView.topAnchor.constraint(equalTo: topAnchor),
            imagesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imagesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            showNextScreenButton.topAnchor.constraint(equalTo: imagesCollectionView.bottomAnchor, constant: 16),
            showNextScreenButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            showNextScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            showNextScreenButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            showNextScreenButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

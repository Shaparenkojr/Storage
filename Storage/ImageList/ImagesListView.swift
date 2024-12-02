import UIKit

class ImagesListView: UIView {
    

    

    
    private lazy var showNextScreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавление изображений на сервер", for: .normal)
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
    
    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let viewModel: ImagesListViewModel
    private let CellViewModel: CellViewModel
    private var images: [ImagesListModel]?
    
    init(frame: CGRect, viewModel: ImagesListViewModel, CellViewModel: CellViewModel) {
        self.viewModel = viewModel
        self.CellViewModel = CellViewModel
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
        cell.viewModel = CellViewModel
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
            showNextScreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            showNextScreenButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            showNextScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            showNextScreenButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            imagesCollectionView.topAnchor.constraint(equalTo: showNextScreenButton.bottomAnchor, constant: 16),
            imagesCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imagesCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imagesCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

}

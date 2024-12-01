

import UIKit
import Combine

class ImageCollectionCell: UICollectionViewCell {
    
    static let identifier: String = String(describing: ImageCollectionCell.self)
    
    private enum Constants {
        static let downloadImageButtonTitle = "Скачать"
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var downloadImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Constants.downloadImageButtonTitle, for: .normal)
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressBar: UIProgressView = {
        let bar = UIProgressView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.isHidden = true
        return bar
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    var viewModel: ImageCellViewModel?
    
    private var subscriptions: Set<AnyCancellable> = []
    private var imageUrl: String?
    private var isLoaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    func configure(_ imageUrl: String) {
        self.imageUrl = imageUrl
        setupBindingForCell()
    }
    
    func configureForCachedImage(_ image: UIImage, _ url: String) {
        imageView.isHidden = false
        downloadImageButton.isHidden = true
        isLoaded = true
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
}

private extension ImageCollectionCell {
    
    func setupBindingForCell() {
            viewModel?.$imageData
                .receive(on: DispatchQueue.main)
                .sink { [weak self] imageData in
                    guard let self = self, let url = self.imageUrl else { return }
                    if let data = imageData[url] {
                        self.isLoaded = true
                        self.downloadImageButton.isHidden = true
                        self.imageView.isHidden = false
                        self.progressBar.isHidden = true
                        self.progressLabel.isHidden = true
                        self.imageView.image = UIImage(data: data)
                        self.imageView.contentMode = .scaleAspectFit
                    } else {
                        self.imageView.isHidden = true
                        self.downloadImageButton.isHidden = false
                    }
                }
                .store(in: &subscriptions)
            
            viewModel?.$imageDataProgress
                .receive(on: DispatchQueue.main)
                .sink { [weak self] progressDict in
                    guard let self = self, let url = self.imageUrl else { return }
                    if let progress = progressDict[url] {
                        if !self.isLoaded {
                            self.downloadImageButton.isHidden = true
                            self.progressLabel.isHidden = false
                            self.progressBar.isHidden = false
                            self.progressBar.setProgress(progress, animated: true)
                            self.progressLabel.text = "\(Int(progress * 100))%"
                        }
                    } else {
                        self.progressBar.isHidden = true
                        self.progressLabel.isHidden = true
                    }
                }
                .store(in: &subscriptions)
        }
    
    @objc
    func downloadButtonTapped() {
        guard let imageUrl = imageUrl else { return }
        viewModel?.loadImage(from: imageUrl)
    }
    
    func setupCell() {
        contentView.addSubview(imageView)
        contentView.addSubview(downloadImageButton)
        contentView.addSubview(progressBar)
        contentView.addSubview(progressLabel)
        
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            downloadImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            downloadImageButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            progressBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
}

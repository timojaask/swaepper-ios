//
//  PurchaseDetailViewController.swift
//  Swapper-iOS
//
//  Created by Timo Jääskeläinen on 21/03/16.
//  Copyright © 2016 Swapper. All rights reserved.
//

import UIKit
import Kingfisher

class PurchaseDetailViewController: UIViewController {
    fileprivate var book: UserBook?
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cancelButton: CustomButton!
    @IBOutlet weak var pickUpButton: CustomButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setContnet(_ book: UserBook) {
        self.book = book
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PurchaseDetailViewController.bequestedBooksSectionCacheItemsChanged(_:)), name: NSNotification.Name(rawValue: AppNotifications.RequestedBooksSectionCacheItemsChanged), object: nil)
        
        reloadBook()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coverImage.kf.cancelDownloadTask()
        NotificationCenter.default.removeObserver(self)
    }
    
    func bequestedBooksSectionCacheItemsChanged(_ notification: Notification) {
        reloadBook()
    }
    
    func reloadBook() {
        let foundBook = RequestedBooksCache.sharedInstance.books.filter { book in
            return book.id == self.book?.id
        }.first
        
        guard let book = foundBook else {
            return
        }
        
        self.book = book
        
        titleLabel.text = book.details.title
        authorLabel.text = book.details.authors.first?.name
        priceLabel.text = "\(Double(book.price)/100.0) €"
        if let coverImageUrl = URL(string: book.details.cover.large) {
            let placeholder = Image(named: "cover_placeholder")
            coverImage.kf.setImage(with: coverImageUrl, placeholder: placeholder, options: [.transition(.fade(1))])
        }
        setState(book.state)
        
        debugPrint("Book state: \(book.state.rawValue)")
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        guard let book = self.book else {
            return
        }
        SwapperApi.sharedInstance.cancelBookRequest(book) { result in
            switch (result) {
            case .success:
                debugPrint("Book cancelled successfully")
                self.navigationController?.popViewController(animated: true)
                return
            case .unknownError:
                debugPrint("Failed to cancel book")
                return
            }
        }
    }
    
    @IBAction func pickUpButtonTapped(_ sender: AnyObject) {
        guard let book = self.book else {
            return
        }
        SwapperApi.sharedInstance.pickUpBook(book) { result in
            switch (result) {
            case .success:
                debugPrint("Book picked up successfully")
                self.navigationController?.popViewController(animated: true)
            case .unknownError:
                debugPrint("Failed to pick up book")
            }
        }
    }
    
    func setState(_ state: State) {
        switch state {
        case .Requested:
            cancelButton.isHidden = false
            pickUpButton.isHidden = true
            statusLabel.text = "REQUESTED"
        case .Accepted:
            cancelButton.isHidden = true
            pickUpButton.isHidden = true
            statusLabel.text = "ACCEPTED"
        case .InTransfer:
            cancelButton.isHidden = true
            pickUpButton.isHidden = false
            statusLabel.text = "IN TRANSACTION"
        case .Sold:
            cancelButton.isHidden = true
            pickUpButton.isHidden = true
            statusLabel.text = "SOLD"
        case .TransferCancelled:
            cancelButton.isHidden = true
            pickUpButton.isHidden = true
            statusLabel.text = "CANCELLED"
        default:
            cancelButton.isHidden = true
            pickUpButton.isHidden = true
            statusLabel.text = ""
        }
    }
}

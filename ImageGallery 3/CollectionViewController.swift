//
//  CollectionViewController.swift
//  ImageGallery 3
//
//  Created by Apple on 15/03/19.
//  Copyright © 2019 Ztack. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDropDelegate {
    
    
    

    // MARK: UICollectionViewDataSource
    var game = Album(photos: [], urls: []){
        didSet{
            print("entered Albums didSet reloadData()")
//            imagesCollectionView.reloadData()
        }
    }
    
    @IBOutlet var imagesCollectionView: UICollectionView!{
        didSet{
            print("didSet imagesCollectionView")
            imagesCollectionView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            imagesCollectionView.delegate = self
            imagesCollectionView.dataSource = self
            imagesCollectionView.dropDelegate = self
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("entered numberOfSections = \(1)")
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("entered numberOfItemsInSection  = \(game.urls.count)")
        return game.urls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Entered cellForItemAt")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        if let image = game.photos[indexPath.item]{
            if let imageCell = cell as? imageCollectionViewCell{//if photo already downloaded
                print("Image already downloaded for index = \(indexPath.item)")
                imageCell.backgroundImage = image
            }else{
                print("case where image not downloaded but cellForItemAt called")
                //Maybe not required as in that case placeholder cell is used
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        print("entered dropSessionDidUpdate")
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        print("Entered canHandle")
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("enetered sizeForItemAt with \n game.photos.count = \(game.photos.count)\n game.urls.count = \(game.urls.count) indexPath.item = \(indexPath.item)")
        let imageSize = self.game.photos[indexPath.item]?.size
        print("imageSize = \(String(describing: imageSize))")
        return CGSize(width: cellWidth, height: cellWidth*((imageSize?.height)! / ((imageSize?.width)!)))
//        return CGSize(width: cellWidth, height: cellWidth*(3/2)  )
    }
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        print("entered performDropWith")
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: self.game.urls.count, section: 0)
        for items in coordinator.items{
            let placeHolderContext = coordinator.drop(items.dragItem,
                                                      to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "imagePlaceHolder")
            )
            print()
            //To Do: download the image and swap placeholder
            items.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                if let url = provider as? URL{
                    if let urlContents = try? Data(contentsOf: url.imageURL){
                        DispatchQueue.main.async {
                            if let url = provider as? URL{
                                placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                    let image = UIImage(data: urlContents)
                                    if image != nil{
                                        self.game.insertData(image, url, at: insertionIndexPath.item)
                                    }else{
                                        placeHolderContext.deletePlaceholder()
                                    }
                                })
                            }else{
                                placeHolderContext.deletePlaceholder()
                            }
                        }
                    }else{
                        placeHolderContext.deletePlaceholder()
                    }
                }else{
                    placeHolderContext.deletePlaceholder()
                }

            }
            
        }
    }
    //MARK: Dragging
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
}

extension CollectionViewController{
    var cellHeight: CGFloat{
        return CGFloat(150.0)
    }
    var cellWidth: CGFloat{
        return CGFloat(150.0)
    }
}

extension URL {
    var imageURL: URL {
        if let url = UIImage.urlToStoreLocallyAsJPEG(named: self.path) {
            // this was created using UIImage.storeLocallyAsJPEG
            return url
        } else {
            // check to see if there is an embedded imgurl reference
            for query in query?.components(separatedBy: "&") ?? [] {
                let queryComponents = query.components(separatedBy: "=")
                if queryComponents.count == 2 {
                    if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                        return url
                    }
                }
            }
            return self.baseURL ?? self
        }
    }
}
extension UIImage
{
    private static let localImagesDirectory = "UIImage.storeLocallyAsJPEG"
    
    static func urlToStoreLocallyAsJPEG(named: String) -> URL? {
        var name = named
        let pathComponents = named.components(separatedBy: "/")
        if pathComponents.count > 1 {
            if pathComponents[pathComponents.count-2] == localImagesDirectory {
                name = pathComponents.last!
            } else {
                return nil
            }
        }
        if var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent(localImagesDirectory)
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                url = url.appendingPathComponent(name)
                if url.pathExtension != "jpg" {
                    url = url.appendingPathExtension("jpg")
                }
                return url
            } catch let error {
                print("UIImage.urlToStoreLocallyAsJPEG \(error)")
            }
        }
        return nil
    }
    
    func storeLocallyAsJPEG(named name: String) -> URL? {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            if let url = UIImage.urlToStoreLocallyAsJPEG(named: name) {
                do {
                    try imageData.write(to: url)
                    return url
                } catch let error {
                    print("UIImage.storeLocallyAsJPEG \(error)")
                }
            }
        }
        return nil
    }
    
    func scaled(by factor: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * factor, height: size.height * factor)
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

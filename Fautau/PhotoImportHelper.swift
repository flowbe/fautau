//
//  PhotoImportHelper.swift
//  Fautau
//
//  Created by Florentin BEKIER on 14/06/2021.
//

import UIKit
import Combine
import Photos
import os.log

/// Helper class containing methods for image import.
class PhotoImportHelper: ObservableObject {
    private let albumName = "Fautau"
    private let fileManager = FileManager.default
    private let dispatchQueue = DispatchQueue(label: "photo-import", qos: .default)

    @Published private var photos: [URL] = []
    private var assetCollection: PHAssetCollection?

    var photosCount: Int {
        return photos.count
    }

    // MARK: - Public methods

    /// Open the document directory in Files app.
    func openDocumentDirectory() {
        if let documentDirectory = try? getDocumentDirectoryURL() {
            var components = URLComponents(url: documentDirectory, resolvingAgainstBaseURL: true)
            components?.scheme = "shareddocuments"
            if let url = components?.url {
                UIApplication.shared.open(url)
            }
        }
    }

    /// Read images in document directory.
    /// - Parameter completion: Completion handler called when all images are fetched. The boolean indicates if the task succeeded or not.
    func fetchImages(completion: @escaping (Bool) -> Void) {
        do {
            let documentDirectory = try getDocumentDirectoryURL()
            let items = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            dispatchQueue.async {
                var photos = [URL]()
                for item in items {
                    if let uti = UTType(filenameExtension: item.pathExtension, conformingTo: .item), uti.conforms(to: .image) {
                        photos.append(item)
                    }
                }
                DispatchQueue.main.async {
                    self.photos = photos
                }
                completion(true)
            }
        } catch {
            os_log(.error, "Failed to fetch images: %@", error as CVarArg)
            completion(false)
        }
    }

    /// Import fetched images to the photo library.
    /// - Parameter completion: Completion handler called when all images are imported. The boolean indicates if the task succeeded or not.
    func importImages(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized || status == .limited else {
                os_log(.error, "Access to the photo library is denied")
                completion(false)
                return
            }
            // TODO: Perform multiple transactions
            PHPhotoLibrary.shared().performChanges {
                let requests = self.photos.compactMap { PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: $0) }
                if let assetCollection = self.assetCollection {
                    let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                    addAssetRequest?.addAssets(requests.compactMap(\.placeholderForCreatedAsset) as NSArray)
                }
            } completionHandler: { success, error in
                if let error = error {
                    os_log(.error, "Failed to import images: %@", error as CVarArg)
                }
                completion(success)
            }
        }
    }

    // MARK: - Private methods

    private func getDocumentDirectoryURL() throws -> URL {
        return try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }

    private func createAlbumIfNeeded() {
        if let assetCollection = self.fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
        } else {
            PHPhotoLibrary.shared().performChanges { [self] in
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            } completionHandler: { success, _ in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                }
            }
        }
    }

    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        return PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject
    }
}

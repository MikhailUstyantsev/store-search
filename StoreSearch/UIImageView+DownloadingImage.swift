//
//  UIImageView+DownloadingImage.swift
//  StoreSearch
//
//  Created by Mikhail Ustyantsev on 31.08.2022.
//

import UIKit
/*
1. After obtaining a reference to the shared URLSession, you create a download task. This is similar to a data task, but it saves the downloaded file to a temporary location on disk instead of keeping it in memory
 
2. Inside the completion handler for the download task, you’re given a URL where you can find the downloaded file — this URL points to a local file rather than an internet address. Of course, you must also check that error is nil before you continue
 
3. With this local URL you can load the file into a Data object and then create an image from that. It’s possible that constructing the UIImage fails, for example, when what you downloaded was not a valid image but a 404 page or something else unexpected. As you can tell, when dealing with networking code, you need to check for errors every step of the way!
 
4. Once you have the image, you can put it into the UIImageView’s image property.
 Because this is UI code you need to do this on the main thread.
 
 !!! NB
 Here’s the tricky thing: it is theoretically possible that the UIImageView no longer exists by the time the image arrives from the server. After all, it may take a few seconds and the user might have navigated away to a different part of the app by then.
 That won’t happen in this part of the app because the image view is part of a table view cell and they get recycled but not thrown away. But later on you’ll use this same code to load an image on a screen that may be closed while the image file is still downloading. In that case, you don’t want to set the image if the UIImageView is not visible anymore.
 That’s why the capture list for this closure includes [weak self], where self now refers to the UIImageView. Inside the DispatchQueue.main.async you need to check whether “self” still exists; if not, then there is no more UIImageView to set the image on
 
 5. After creating the download task, you call resume() to start it, and then return the URLSessionDownloadTask object to the caller. Why return it? That gives the app the opportunity to call cancel() on the download task if necessary. 
 */


extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1
        let downloadTask = session.downloadTask(with: url) { [weak self] url, _,
            error in
            // 2
            if error == nil, let url = url,
               let data = try? Data(contentsOf: url),
               // 3
               let image = UIImage (data: data) {
                // 4
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        }
        // 5
        downloadTask.resume()
        return downloadTask
    }
}

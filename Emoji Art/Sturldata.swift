//
//  Sturldata.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import CoreTransferable

/// A type which represents either a `String`, a `URL` or a `Data`.
enum Sturldata: Transferable {
    case string(String)
    case url(URL)
    case data(Data)
    
    /// Initializes a `Sturldata` instance from a `URL`.
    ///
    /// If the URL contains image data in a `data` scheme, this initializer converts the data into a `.data` case.
    /// Otherwise, it extracts the image URL (if embedded within the query parameters) and initializes with the `.url` case.
    ///
    /// - parameter url: The `URL` to initialize from.
    init(url: URL) {
        if let imageData = url.dataSchemeImageData {
            self = .data(imageData)
        } else {
            self = .url(url.imageURL)
        }
    }
    
    /// Initializes a `Sturldata` instance from a `String`.
    ///
    /// If the string resembles a URL (starts with "http"), this initializer attempts to treat it as a URL and initializes with the `.url` case.
    /// Otherwise, it initializes with the `.string` case.
    ///
    /// - parameter string: The `String` to initialize from.
    init(string: String) {
        // if the string looks like a URL, we're treat it like one
        if string.hasPrefix("http"), let url = URL(string: string) {
            self = .url(url.imageURL)
        } else {
            self = .string(string)
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Sturldata(string: $0) }
        ProxyRepresentation { Sturldata(url: $0) }
        ProxyRepresentation { Sturldata.data($0) }
    }
}


extension URL {
    /// A computed property that attempts to extract an image URL embedded within the query parameters of a URL.
    ///
    /// Some search engines provide URLs that contain another URL embedded within the query string,
    /// typically under a parameter like `imgurl`. This property searches
    /// the query items for the first valid URL and returns it if found.
    ///
    /// - returns: The first embedded URL if it exists, otherwise returns `self`.
    ///
    /// Example:
    /// ```swift
    /// let url = URL(string: "https://searchresult.searchengine.com?imgurl=https://actualimageurl.jpg")!
    /// let imageURL = url.imageURL // Returns https://actualimageurl.jpg
    /// ```
    var imageURL: URL {
        if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value, value.hasPrefix("http"),
                   let imgurl = URL(string: value) {
                    return imgurl
                }
            }
        }
        return self
    }
    
    /// A computed property that returns the image data from a data scheme URL, if applicable.
    ///
    /// This property is useful for URLs that follow the data scheme format, such as
    /// `data:image/jpeg;base64,<base64 encoded image data>`. These URLs are typically used for small images like thumbnails.
    ///
    /// - Returns: The decoded image data if the URL is a data scheme with a base64-encoded image, otherwise `nil`.
    ///
    /// Example:
    /// ```swift
    /// let url = URL(string: "data:image/jpeg;base64,<base64-encoded-data>")!
    /// let imageData = url.dataSchemeImageData // Returns decoded Data or nil if not applicable
    /// ```
    var dataSchemeImageData: Data? {
        let urlString = absoluteString
        // is this a data scheme url with some sort of image as the mime type?
        if urlString.hasPrefix("data:image") {
            // yes, find the comma that separates the meta info from the image data
            if let comma = urlString.firstIndex(of: ","), comma < urlString.endIndex {
                let meta = urlString[..<comma]
                // we can only handle base64 encoded data
                if meta.hasSuffix("base64") {
                    let data = String(urlString.suffix(after: comma))
                    // get the data
                    if let imageData = Data(base64Encoded: data) {
                        return imageData
                    }
                }
            }
        }
        // not a data scheme or the data doesn't seem to be a base64 encoded image
        return nil
    }
}

extension Collection {
    // this will crash if after >= endIndex
    func suffix(after: Self.Index) -> Self.SubSequence {
        suffix(from: index(after: after))
    }
}

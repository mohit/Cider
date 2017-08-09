//
//  Cider.swift
//  Cider
//
//  Created by Scott Hoyt on 8/4/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

public struct Cider {
    private let urlBuilder: UrlBuilder
    private let session: URLSession

    // MARK: Initialization

    init(urlBuilder: UrlBuilder, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.urlBuilder = urlBuilder
        self.session = URLSession(configuration: configuration)
    }

    public init(storefront: Storefront, developerToken: String, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        let urlBuilder = CiderUrlBuilder(storefront: storefront, developerToken: developerToken)
        self.init(urlBuilder: urlBuilder, configuration: configuration)
    }

    // MARK: Requests

    public func search(term: String, limit: Int? = nil, types: [MediaType]? = nil, completion: ((SearchResults?, Error?) -> Void)?) {
        let request = urlBuilder.searchRequest(term: term, limit: limit, types: types)
        fetch(request, completion: completion)
    }

    public func artist(id: String, completion: ((Result<MediaResult<ArtistAttributes>>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .artists, id: id)
        fetch(request, completion: completion)
    }

    public func album(id: String, completion: ((Result<MediaResult<AlbumAttributes>>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .albums, id: id)
        fetch(request, completion: completion)
    }

    public func song(id: String, completion: ((Result<MediaResult<TrackAttributes>>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .songs, id: id)
        fetch(request, completion: completion)
    }

    // MARK: Helpers

    private func fetch<T: Decodable>(_ request: URLRequest, completion: ((T?, Error?) -> Void)?) {
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion?(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(T.self, from: data)
                completion?(results, nil)
            } catch {
                completion?(nil, error)
            }
        }
    }
}
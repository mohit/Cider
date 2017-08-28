//
//  CiderClient.swift
//  Cider
//
//  Created by Scott Hoyt on 8/4/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

/// A client for submitting requests to the Apple Music API.
public struct CiderClient {
    private let urlBuilder: UrlBuilder
    private let fetcher: UrlFetcher

    // MARK: URLFetcher

    /**
     Default `UrlFetcher`

     A `URLSession` with the default `URLSessionConfiguration`
     */
    public static var defaultURLFetcher: UrlFetcher {
        return URLSession(configuration: URLSessionConfiguration.default)
    }

    // MARK: Initialization

    init(urlBuilder: UrlBuilder, urlFetcher: UrlFetcher = CiderClient.defaultURLFetcher) {
        self.urlBuilder = urlBuilder
        self.fetcher = urlFetcher
    }

    /**
     Initialize a `CiderClient`

     - parameters:
       - storefront: The `Storefront` to submit requests to.
       - developerToken: The Apple Music developer token to use in requests.
       - urlFetcher: The `UrlFetcher` to use for processing requests. Defaults to a `URLSession` with the default `URLSessionConfiguration`.
     */
    public init(storefront: Storefront, developerToken: String, urlFetcher: UrlFetcher = CiderClient.defaultURLFetcher) {
        let urlBuilder = CiderUrlBuilder(storefront: storefront, developerToken: developerToken)
        self.init(urlBuilder: urlBuilder, urlFetcher: urlFetcher)
    }

    // MARK: Search

    /**
     Search the Apple Music catalog.

     - parameters:
       - term: The term to search for.
       - limit: The amount of results to return.
       - offset: The offset to use for paginating results.
       - types: The `MediaType`s to limit the search to.
       - completion: The completion handler to call with the results of the search.
     */
    public func search(term: String, limit: Int? = nil, offset: Int? = nil, types: [MediaType]? = nil, completion: ((ResponseRoot<SearchResults>?, Error?) -> Void)?) {
        let request = urlBuilder.searchRequest(term: term, limit: limit, offset: offset, types: types)
        fetch(request, completion: completion)
    }

    /**
     Get hints for search terms to use searching the Apple Music catalog.

     - parameters:
       - term: The term to search for.
       - limit: The amount of results to return.
       - types: The `MediaType`s to limit the search to.
       - completion: The completion handler to call with the results of the search hints.
     */
    public func searchHints(term: String, limit: Int? = nil, types: [MediaType]? = nil, completion: ((ResponseRoot<SearchHints>?, Error?) -> Void)?) {
        let request = urlBuilder.searchHintsRequest(term: term, limit: limit, types: types)
        fetch(request, completion: completion)
    }

    // MARK: Lookup

    /**
     Lookup an artist by id.

     - parameters:
       - id: The id of the artist to lookup.
       - include: The relationships to include in the lookup.
       - completion: The handler to call with the results.
     */
    public func artist(id: String, include: [Include]? = nil, completion: ((ResponseRoot<Artist>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .artists, id: id, include: include)
        fetch(request, completion: completion)
    }

    /**
     Lookup an album by id.

     - parameters:
       - id: The id of the album to lookup.
       - include: The relationships to include in the lookup.
       - completion: The handler to call with the results.
     */
    public func album(id: String, include: [Include]? = nil, completion: ((ResponseRoot<Album>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .albums, id: id, include: include)
        fetch(request, completion: completion)
    }

    /**
     Lookup a song by id.

     - parameters:
       - id: The id of the song to lookup.
       - include: The relationships to include in the lookup.
       - completion: The handler to call with the results.
     */
    public func song(id: String, include: [Include]? = nil, completion: ((ResponseRoot<Track>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .songs, id: id, include: include)
        fetch(request, completion: completion)
    }

    /**
     Lookup a playlist by id.

     - parameters:
       - id: The id of the playlist to lookup.
       - include: The relationships to include in the lookup.
       - completion: The handler to call with the results.
     */
    public func playlist(id: String, include: [Include]? = nil, completion: ((ResponseRoot<Playlist>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .playlists, id: id, include: include)
        fetch(request, completion: completion)
    }

    /**
     Lookup a music video by id.

     - parameters:
       - id: The id of the music video to lookup.
       - include: The relationships to include in the lookup.
       - completion: The handler to call with the results.
     */
    public func musicVideo(id: String, include: [Include]? = nil, completion: ((ResponseRoot<MusicVideo>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .musicVideos, id: id, include: include)
        fetch(request, completion: completion)
    }

    /**
     Lookup a curator by id.

     - parameters:
       - id: The id of the curator to lookup.
       - include: The relationships to include in the lookup.
       - completion: The handler to call with the results.
     */
    public func curator(id: String, include: [Include]? = nil, completion: ((ResponseRoot<Curator>?, Error?) -> Void)?) {
        let request = urlBuilder.fetchRequest(mediaType: .curators, id: id, include: include)
        fetch(request, completion: completion)
    }

    // MARK: Relationships

    /**
     Get the related resources for a `Relationship`.

     - parameters:
       - related: The relationship to get.
       - limit: The maximum amount of results to return.
       - offset: The offset to use for pagination.
       - completion: The handler to call with the results.
     */
    public func get<T>(related: Relationship<T>, limit: Int? = nil, offset: Int? = nil, completion: ((ResponseRoot<T>?, Error?) -> Void)?) {
        let path = related.href
        let request = urlBuilder.relationshipRequest(path: path, limit: limit, offset: offset)
        fetch(request, completion: completion)
    }

    // MARK: Helpers

    private func fetch<T: Decodable>(_ request: URLRequest, completion: ((T?, Error?) -> Void)?) {
        fetcher.fetch(request: request) { (data, error) in
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

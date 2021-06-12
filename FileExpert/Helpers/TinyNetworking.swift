//
//  TinyNetworking.swift
//  FileExpert
//
//  Created by new on 6/11/21.
//

import Foundation

struct Resource<A> {
    var method: String = "GET"
    var body: Data? = nil
    let id: String
    
    let parseResult: (Data) -> Result<A>
}

struct ParseError: Error {}

extension Resource where A: RangeReplaceableCollection {
    init(id: String, parseElementJSON parse: @escaping (Any) -> A.Element?) {
        self.id = id
        self.parseResult = { data in
            guard
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonArray = json as? [Any]
            else { return .error(ParseError()) }
            let items = jsonArray.compactMap(parse)
            guard jsonArray.count == items.count else { return .error(ParseError()) }
            return .success(A(items))
        }
    }
}

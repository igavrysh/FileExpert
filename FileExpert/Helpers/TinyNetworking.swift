//
//  TinyNetworking.swift
//  FileExpert
//
//  Created by new on 6/11/21.
//

import Foundation

struct Resource<A> {
    var body: [SheetRecord]? = nil
    let parseResult: ([SheetRecord]) -> Result<A>
}

struct ParseError: Error {}

extension Resource where A: RangeReplaceableCollection {
    init(id: String, parseElementFromSheetRecords parse: @escaping (Any) -> A.Element?) {
        self.parseResult = { sheetRecords in
            let items = sheetRecords.compactMap(parse)
            guard sheetRecords.count == items.count else { return .error(ParseError()) }
            return .success(A(items))
        }
    }
}

//
//  GoogleService.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

class SpreadsheetService {
    
    static let shared = SpreadsheetService()
    
    private static let SREADSHEET_ID = "1rcSWbPMhxGrDCAmge9x8Yr7k8wHVijP1jsiEZpv_Bfk"
    private static let RANGE = "Sheet1"
    private static let API_KEY = "AIzaSyBUXS1Crn_5IxInmyZhw6XoA0P43JbV4Zc"
    
    private let service = GTLRSheetsService()
    
    func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> ()) -> NetworkTask {
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(
                withSpreadsheetId: SpreadsheetService.SREADSHEET_ID,
                range: SpreadsheetService.RANGE)
        service.apiKey = SpreadsheetService.API_KEY

        let t = service.executeQuery(query) { (ticket, result, error) in
            DispatchQueue.global(qos: .background).async {
                if let e = error {
                    DispatchQueue.main.async {
                        completion(.error(e))
                    }
                    return
                }
                
                guard let valueRange = result as? GTLRSheets_ValueRange,
                      let rows = valueRange.values as? [[String]]
                else {
                    DispatchQueue.main.async {
                        completion(.error(self.errorWithDesc("Incorrect spreadsheet format")))
                    }
                    return
                }
                
                var jsonArray: [[String: Any]] = []
                for row in rows {
                    // load only those items that are attached to current folder
                    // TODO: review this logic and adjust when switched to prod level API
                    if resource.id == row[1] {
                        if (row.count != 4) {
                            completion(.error(self.errorWithDesc("Error: incorrect spreadsheet format")))
                            return
                        } else {
                            let json: [String: Any] = [Item.idKey: row[0], Item.nameKey: row[3], Item.isDirectoryKey: row[2] == "d", Item.parentFolderKey: row[1]]
                            jsonArray.append(json)
                        }
                    }
                }
                let d = try! JSONSerialization.data(withJSONObject: jsonArray, options: [])
                DispatchQueue.main.async {
                    completion(resource.parseResult(d))
                }
            }
        }
        return SpreadsheetNetworkTask(with: t)
    }
    
    func addItem(_ item: Item, completion: @escaping (Result<Item>) -> ()) -> NetworkTask {
        guard let directory = item.parent else {
            fatalError("Incorrect File entity, missing File Directory")
        }
        
        let valueRange = GTLRSheets_ValueRange.init();
        
        if item is File {
            valueRange.values = [[item.id, directory.id, "f", item.name]]
        } else {
            valueRange.values = [[item.id, directory.id, "d", item.name]]
        }
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(
            withObject: valueRange,
            spreadsheetId: SpreadsheetService.SREADSHEET_ID,
            range: SpreadsheetService.RANGE
        )
        query.valueInputOption = kGTLRSheetsValueInputOptionUserEntered
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        let t = service.executeQuery(query) { (ticket, result, error) in
            if let e = error {
                completion(.error(e))
                return
            }
            
            guard let valueRange = result as? GTLRSheets_ValueRange,
                  let rows = valueRange.values as? [[String]]
            else {
                completion(.error(self.errorWithDesc("Incorrect spreadsheet format")))
                return
            }
            
            completion(.success(item))
        }
        return  SpreadsheetNetworkTask(with: t)
    }
    
    private func errorWithDesc(_ desc: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: desc]) as Error
    }
}


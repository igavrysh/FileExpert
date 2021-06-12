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
    
    func fetchSheet(completion: @escaping (Sheet?, Error?) -> ()) {
        var sheet = Sheet()
        
        //let queryText = GTLRSheetsQuery_SpreadsheetsValuesBatchGetByDataFilter(
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(
                withSpreadsheetId: SpreadsheetService.SREADSHEET_ID,
                range: SpreadsheetService.RANGE)
        
        service.apiKey = SpreadsheetService.API_KEY
        
        service.executeQuery(query) { (ticket, result, error) in
            DispatchQueue.global(qos: .background).async {
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let valueRange = result as? GTLRSheets_ValueRange,
                      let rows = valueRange.values as? [[String]]
                else {
                    completion(nil, self.errorWithDesc("Incorrect spreadsheet format"))
                    return
                }
                
                var error: Error?
                for row in rows {
                    if (row.count != 4) {
                        error = self.errorWithDesc("Error: incorrect spreadsheet format")
                    } else {
                        sheet.rows.append(SheetRecord(
                                            id: row[0],
                                            parentId: row[1],
                                            type: row[2],
                                            name: row[3]))
                    }
                }
                completion(sheet, error)
            }
        }
    }
    
    func addFile(_ file: File, completion: ((Sheet?, Error?) -> ())?) {
        guard let directory = file.parent else {
            completion?(nil, self.errorWithDesc("Incorrect File entity, missing File Directory"))
            return
        }
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [
            [file.id, directory.id, "f", file.name]
        ]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(
            withObject: valueRange,
            spreadsheetId: SpreadsheetService.SREADSHEET_ID,
            range: SpreadsheetService.RANGE
        )
        query.valueInputOption = kGTLRSheetsValueInputOptionUserEntered
        service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
        service.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                completion?(nil, error)
                return
            }
            
            guard let valueRange = result as? GTLRSheets_ValueRange,
                  let rows = valueRange.values as? [[String]]
            else {
                completion?(nil, self.errorWithDesc("Incorrect spreadsheet format"))
                return
            }
            
            completion?(nil, nil)
        }
    }
    
    private func errorWithDesc(_ desc: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: desc]) as Error
    }
}


//
//  GoogleService.swift
//  FileExpert
//
//  Created by new on 5/27/21.
//

import GoogleSignIn
import GoogleAPIClientForREST

class SheetService {
    
    static let shared = SheetService()
    
    private static let SREADSHEET_ID = "1rcSWbPMhxGrDCAmge9x8Yr7k8wHVijP1jsiEZpv_Bfk"
    private static let RANGE = "Sheet1"
    private static let API_KEY = "AIzaSyBUXS1Crn_5IxInmyZhw6XoA0P43JbV4Zc"
    
    private let service = GTLRSheetsService()
    
    func fetchSheet(completion: @escaping (Sheet?, Error?) -> ()) {
        var sheet = Sheet()
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(
                withSpreadsheetId: SheetService.SREADSHEET_ID,
                range: SheetService.RANGE)
        
        service.apiKey = SheetService.API_KEY
        
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
    /*
    func addFile(_ file: File, completion: @escaping (Sheet?, Error?) -> ()) {
        guard let directory = file.parent else {
            completion(nil, self.errorWithDesc("Incorrect File entity, missing File Directory"))
            return
        }
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [
            [file.id, directory.id, "f", file.name]
        ]
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(
            withObject: valueRange,
            spreadsheetId: SheetService.SREADSHEET_ID,
            range: SheetService.RANGE
        )
        
        service.executeQuery(query) { (ticket, result, error) in
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
            
            completion(nil, nil)
        }
    }*/
    
    private func errorWithDesc(_ desc: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: desc]) as Error
    }
}


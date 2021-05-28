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
    
    private static let SREADSHEET_ID = "1oL1cByCpMXJMz6ifaKDiK6bZC2xE2HkRA4jwHRtRuj8"
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
    
    private func errorWithDesc(_ desc: String) -> Error {
        return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: desc]) as Error
    }
}


//
//  JSON.swift
//  Luna
//
//  Created by Andrew Shepard on 2/18/16.
//  Copyright © 2016 Andrew Shepard. All rights reserved.
//

import Foundation

typealias JSON = [String: AnyObject]

protocol JSONRepresentable {
    func toJSON() throws -> JSON
}

protocol JSONConstructable {
    init?(json: JSON)
}

enum JSONError: ErrorProtocol {
    case BadFormat
    case NoJSON(ErrorProtocol)
}

extension NSData: JSONRepresentable {
    func toJSON() throws -> JSON {
        do {
            let obj = try NSJSONSerialization.jsonObject(with: self, options: [])
            guard let json = obj as? JSON else { throw JSONError.BadFormat }
            return json
        } catch (let error) {
            throw JSONError.NoJSON(error)
        }
    }
}

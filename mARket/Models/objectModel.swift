//
//  objectModel.swift
//  mARket
//
//  Created by Michael Benton on 4/17/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit

struct Object: Codable {
    let comments: [comment]?
    let _id: String?
    let storename: String
    let name: String
    let path: String?
    let thumbnail: thumbnail
    let url: String?
    let createdAt: String?
    let updatedAt: String?
    let __v: Int?
    let description: String?
    let price: String?
}

struct comment: Codable {
    let comment: String?
    let author_id: String?
    let author: String?
    let _id: String?
    let createdAt: String?
    let updatedAt: String?
}

struct thumbnail: Codable {
    let url: String
    let path: String
    let _id: String
}

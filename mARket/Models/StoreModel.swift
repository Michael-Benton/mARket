//
//  StoreModel.swift
//  mARket
//
//  Created by Michael Benton on 4/16/18.
//  Copyright © 2018 Michael Benton. All rights reserved.
//

import UIKit

struct Store: Codable {
    let _id: String
    let updatedAt: String
    let createdAt: String
    let name: String
    let logo: logo
    let gps: gps
    let contact_info: contact_info
    let address_info: address_info
    let objects: objects
    let __v: Int
    let business_hrs: [business_hrs]
}

struct gps: Codable {
    let longitude: Double
    let latitude: Double
}

struct logo: Codable {
    let url: String
    let path: String
}

struct contact_info: Codable {
    let phone: Int
    let email: String
    let website: String
    let _id: String
}

struct address_info: Codable {
    let street: String
    let city: String
    let state: String
    let zip: Int
    let _id: String
}

struct objects: Codable {
    let model: String
    let _id: String
}

struct business_hrs: Codable {
    let day: String
    let _id: String
    let hours: [hours]
}

struct hours: Codable {
    let open: Int
    let open_min: Int
    let closed: Int
    let closed_min: Int
    let _id: String
}



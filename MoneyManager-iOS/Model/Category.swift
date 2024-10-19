//
//  Category.swift
//  MoneyManager-iOS
//
//  Created by Tarikul Islam on 8/10/24.
//

import SwiftUI

protocol Category {
    var name: String { get }
    var icon: String { get }
    var color: Color { get }
}

extension Transaction {
    enum MainCategory: Category, Hashable, Identifiable, CaseIterable {
        var id: Self { return self }
        
        case Groceries
        case Restaurant
        case Shopping
        case Housing
        case Transportation
        case Communication
        case Life_Entertainment
        
        
        var name: String {
            switch self {
            case .Groceries:            return "Groceries"
            case .Restaurant:           return "Restaurant"
            case .Shopping:             return "Shopping"
            case .Housing:              return "Housing"
            case .Transportation:       return "Transportation"
            case .Communication:        return "Communication"
            case .Life_Entertainment:   return "Life & Entertainment"
            }
        }
        
        var icon: String {
            switch self {
            case .Groceries:          return "cart.fill"
            case .Restaurant:         return "fork.knife"
            case .Shopping:           return "bag"
            case .Housing:            return "house"
            case .Transportation:     return "bus"
            case .Communication:      return "iphone"
            case .Life_Entertainment: return "gamecontroller"
            }
        }
        
        var color: Color {
            switch self {
            case .Groceries:          return .red
            case .Restaurant:         return .red
            case .Shopping:           return .blue
            case .Housing:            return .orange
            case .Transportation:     return .gray
            case .Communication:      return .black
            case .Life_Entertainment: return .green
            }
        }
        
        var Subcategories: [Subcategory] {
            switch self {
            case .Groceries:
                return [.Bar_Cafe, .Fast_Food]
            case .Restaurant:
                return [.Alcohol, .Bar_Cafe, .Cigarette]
            case .Shopping:
                return [.Books, .Jewels_Accessories, .Kids, .Leasing, .Gifts]
            case .Housing:
                return [.Internet, .Sanitary, .Drugs_MedicalTools, .Gifts, .Health_Beauty, .TV_Streaming]
            case .Transportation:
                return [.Public_Transport, .Vehicle_Insurance, .Vehicle_Maintainance, .Taxi, .Business_Trips, .Fuel]
            case .Communication:
                return [.Phone, .Postal_Service, .Family_Party]
            case .Life_Entertainment:
                return [.ContentSubscription, .Holiday_Trips, .Phone, .Sports, .Sports]
            }
        }
    }
    
    enum Subcategory: Category, Hashable, Identifiable, CaseIterable {
        var id: Self { return self }
        
        case Fast_Food
        case Bar_Cafe
        case Clothes_Shoes
        case Jewels_Accessories
        case Health_Beauty
        case Kids
        case Gifts
        case Sanitary
        case Drugs_MedicalTools
        case Fuel
        case Parking
        case Rentals
        case Vehicle_Insurance
        case Leasing
        case Vehicle_Maintainance
        case Family_Party
        case Holiday_Trips
        case Alcohol
        case Cigarette
        case TV_Streaming
        case Books
        case ContentSubscription
        case Sports
        case Postal_Service
        case Software
        case Internet
        case Phone
        case Public_Transport
        case Taxi
        case Long_Tour
        case Business_Trips
        
        
        var name: String {
            switch self {
            case .Fast_Food:                return "Fast Food"
            case .Bar_Cafe:                 return "Bar & Cafe"
            case .Clothes_Shoes:            return "Cloths & Shoes"
            case .Jewels_Accessories:       return "Jewels & Accessories"
            case .Health_Beauty:            return "Health & Beauty"
            case .Kids:                     return "Kids"
            case .Gifts:                    return "Gifts"
            case .Sanitary:                 return "Sanitary"
            case .Drugs_MedicalTools:       return "Drugs and Medicals"
            case .Fuel:                     return "Fuel"
            case .Parking:                  return "Parking"
            case .Rentals:                  return "Rentals"
            case .Vehicle_Insurance:        return "Vehicle Insurance"
            case .Leasing:                  return "Leasing"
            case .Vehicle_Maintainance:     return "Vehicle Maintanance"
            case .Family_Party:             return "Family Party"
            case .Holiday_Trips:            return "Holiday Trips"
            case .Alcohol:                  return "Alcohol"
            case .Cigarette:                return "Cigarettes"
            case .TV_Streaming:             return "TV Streaming"
            case .Books:                    return "Books"
            case .ContentSubscription:      return "Content Subscription"
            case .Sports:                   return "Sports"
            case .Postal_Service:           return "Postal Service"
            case .Software:                 return "Software"
            case .Internet:                 return "Internet"
            case .Phone:                    return "Phone"
            case .Public_Transport:         return "Public Transport"
            case .Taxi:                     return "Taxi"
            case .Long_Tour:                return "Long Tour"
            case .Business_Trips:           return "Business Trips"
            }
        }
        
        var icon: String {
            switch self {
            case .Fast_Food:            return "fork.knife.circle.fill"
            case .Bar_Cafe:             return "cup.and.heat.waves.fill"
            case .Clothes_Shoes:        return "hanger"
            case .Jewels_Accessories:   return "peacesign"
            case .Health_Beauty:        return "face.dashed.fill"
            case .Kids:                 return "figure.2.and.child.holdinghands"
            case .Gifts:                return "app.gift.fill"
            case .Sanitary:             return "toilet.fill"
            case .Drugs_MedicalTools:   return "cross.case.fill"
            case .Fuel:                 return "Fuel"
            case .Parking:              return "car.rear.waves.up"
            case .Rentals:              return "directcurrent"
            case .Vehicle_Insurance:    return "car"
            case .Leasing:              return "mug.fill"
            case .Vehicle_Maintainance: return "car"
            case .Family_Party:         return "balloon.2.fill"
            case .Holiday_Trips:        return "balloon.2.fill"
            case .Alcohol:              return "mug.fill"
            case .Cigarette:            return "smoke.circle.fill"
            case .TV_Streaming:         return "network.badge.shield.half.filled"
            case .Books:                return "books.vertical.fill"
            case .ContentSubscription:  return "network.badge.shield.half.filled"
            case .Sports:               return "figure.australian.football"
            case .Postal_Service:       return "envelope.badge.person.crop.fill"
            case .Software:             return "desktopcomputer"
            case .Internet:             return "globe.europe.africa.fill"
            case .Phone:                return "phone"
            case .Public_Transport:     return "bus.doubledecker"
            case .Taxi:                 return "car.front.waves.down.fill"
            case .Long_Tour:            return "sharedwithyou.circle"
            case .Business_Trips:       return "person.crop.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .Fast_Food:            return .red
            case .Bar_Cafe:             return .red
            case .Clothes_Shoes:        return .cyan
            case .Jewels_Accessories:   return .indigo
            case .Health_Beauty:        return .red
            case .Kids:                 return .green
            case .Gifts:                return .yellow
            case .Sanitary:             return .accentColor
            case .Drugs_MedicalTools:   return .purple
            case .Fuel:                 return .mint
            case .Parking:              return .red
            case .Rentals:              return .blue
            case .Vehicle_Insurance:    return .brown
            case .Leasing:              return .yellow
            case .Vehicle_Maintainance: return .gray
            case .Family_Party:         return .red
            case .Holiday_Trips:        return .blue
            case .Alcohol:              return .cyan
            case .Cigarette:            return .brown
            case .TV_Streaming:         return .accentColor
            case .Books:                return .gray
            case .ContentSubscription:  return .orange
            case .Sports:               return .orange
            case .Postal_Service:       return .red
            case .Software:             return .red
            case .Internet:             return .blue
            case .Phone:                return .blue
            case .Public_Transport:     return .green
            case .Taxi:                 return .yellow
            case .Long_Tour:            return .brown
            case .Business_Trips:       return .red
            }
        }
    }
}

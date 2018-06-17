//
//  CreditsManager.swift
//  iRogue
//
//  Created by Michael McGhan on 5/18/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

import UIKit

public class CreditsManager : CreditsControllerService {
    // ToDo: refactor to use CaseIterable protocol when available (Swift 4.2+)
    private enum SECTION_KEY : String {
        case Credits = "Credits"
        case Acknowledgements = "Acknowledgements"
        case SpecialThanks = "Special Thanks"
        
        public static let allValues = [Credits, Acknowledgements, SpecialThanks]
        var index : Int {
            return SECTION_KEY.allValues.index(of: self)!
        }
    }

    private static var acknowledgements = [
        SECTION_KEY.Credits : [
            Acknowledgement(creditTo: "lynergy.com",
                            title: "Tips on using InAppSettingsKit",
                            link: URL(string: "http://www.lynergy.com/Blog/23/2011/3/7/Using+InAppSettingsKit+to+replicate+iPhone+settings+within+your+iPhone+App"),
                            license: nil
            ),
            Acknowledgement(creditTo: "useyourloaf.com",
                            title: "Acknowledgement Popup",
                            link: URL(string: "https://useyourloaf.com/blog/stack-view-background-color/"),
                            license: nil
            ),
            Acknowledgement(creditTo: "Matthew Cheok",
                            title: "Kalidescope (lexical parser)",
                            link: URL(string: "https://github.com/matthewcheok/Kaleidoscope"),
                            license: URL(string: "https://github.com/matthewcheok/Kaleidoscope/blob/master/LICENSE")
            ),
            Acknowledgement(creditTo: "Juguang XIAO",
                            title: "Kalidescope conversion to Swift 4",
                            link: URL(string: "https://github.com/between40and2"),
                            license: nil
            ),
        ]
    ]
    
    public func getItemCount(for section: Int) -> Int {
        let sectionKey = SECTION_KEY.allValues[section]
        return CreditsManager.acknowledgements[sectionKey]?.count ?? 0
    }

    public func getSectionCount() -> Int {
        return SECTION_KEY.allValues.count
    }
    
    public func getAcknowledgement(for section: Int, row: Int) -> CreditsManager.Acknowledgement? {
        let sectionKey = SECTION_KEY.allValues[section]
        if let acknowledgement = CreditsManager.acknowledgements[sectionKey]?[row] {
            return acknowledgement
        }
        return nil
    }
    
    public func getTitle(for section: Int) -> String? {
        return SECTION_KEY.allValues[section].rawValue
    }
    
    public struct Acknowledgement {
        let creditTo : String
        let title : String
        let link : URL?
        let license : URL?
    }
}

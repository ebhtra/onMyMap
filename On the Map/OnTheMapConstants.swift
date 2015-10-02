//
//  OnTheMapConstants.swift
//  On the Map
//
//  Created by Ethan Haley on 9/29/15.
//  Copyright (c) 2015 Ethan Haley. All rights reserved.
//

extension OnTheMapClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: API Keys
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTkey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let BaseParseRequest = "https://api.parse.com/1/classes/StudentLocation"
        static let UdacityBaseSecureUrl = "https://www.udacity.com/api/"
        static let UdacitySignupURL = "https://www.google.com/url?q=https%3A%2F%2Fwww.udacity.com%2Faccount%2Fauth%23!%2Fsignin&sa=D&sntz=1&usg=AFQjCNERmggdSkRb9MFkqAW_5FgChiCxAQ"
    }
    
    // MARK: - Methods
    struct Methods {
        
        static let UdacitySession = "session"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let Limit = "limit"
        static let Order = "order"
        static let Skip = "skip"
    }

        
}


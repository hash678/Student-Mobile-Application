//
//  paperObject.swift
//  Nixor Student Application
//
//  Created by Hassan Abbasi on 07/07/2018.
//  Copyright © 2018 Hassan Abbasi. All rights reserved.
//

import Foundation
struct paperObject:Equatable{
    var month,
    year,
    variant,
    type,
    documentID,
    url:String?
    
    static func == (lhs: paperObject, rhs: paperObject) -> Bool {
        return lhs.url == rhs.url
    }
    
    
   
     init(monthO: String? ,yearO: String? ,variantO:String?,typeO:String?,url:String)  {
     
        if let month = monthO{
            self.month = month
        }else{
            self.month = "error"
        }
        if let year = yearO{
            self.year = year
        }else{
            self.year = "error"
        }
        if let variant = variantO{
            self.variant = variant
        }else{
            self.variant = "error"
        }
        
        if let type = typeO{
            self.type = type
        }else{
            self.type = "error"
        }
        
        self.url = url
        
        
    }

}

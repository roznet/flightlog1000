//
//  FlightSummaryFuelDataSource.swift
//  FlightLog1000
//
//  Created by Brice Rosenzweig on 12/06/2022.
//

import UIKit
import OSLog
import RZUtils
import RZUtilsSwift

class FlightSummaryFuelDataSource: TableDataSource {

    let flightSummary : FlightSummary
    let displayContext : DisplayContext
    
    //               Total    Left   Right
    //    Start
    //    End
    //    Remaining
    
    init(flightSummary : FlightSummary, displayContext : DisplayContext = DisplayContext()){
        self.flightSummary = flightSummary
        self.displayContext = displayContext
        super.init(rows: 4, columns: 5, frozenColumns: 1, frozenRows: 1)
    }
    
    //MARK: - delegate
        
    var titleAttributes : [NSAttributedString.Key:Any] = [.font:UIFont.boldSystemFont(ofSize: 14.0)]
    var cellAttributes : [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize: 14.0)]
    
    override func prepare() {
        
        self.cellHolders  = []
        self.geometries = []
        
        self.cellAttributes = ViewConfig.shared.cellAttributes
        self.titleAttributes = ViewConfig.shared.titleAttributes
        
        for title in [ "Fuel", "Total", "Left", "Right", "Totalizer" ] {
            self.cellHolders.append(CellHolder(string: title, attributes: self.titleAttributes))
            let geometry = RZNumberWithUnitGeometry()
            geometry.defaultUnitAttribute = self.cellAttributes
            geometry.defaultNumberAttribute = self.cellAttributes
            geometry.numberAlignment = .decimalSeparator
            geometry.unitAlignment = .left
            geometry.alignment = .center
            self.geometries.append(geometry)
        }
        for (name,fuel,totalizer) in [("Start", self.flightSummary.fuelStart,FuelQuantity.zero),
                                      ("End", self.flightSummary.fuelEnd,FuelQuantity.zero),
                                      ("Used", self.flightSummary.fuelUsed,self.flightSummary.fuelTotalizer)
        ] {
            self.cellHolders.append(CellHolder(string: name, attributes: self.titleAttributes))
            var geoIndex = 1
            for fuelVal in [fuel.total, fuel.left, fuel.right, totalizer.total] {
                if fuelVal != 0.0 {
                    let nu = self.displayContext.numberWithUnit(gallon: fuelVal)
                    self.geometries[geoIndex].adjust(for: nu)
                    self.cellHolders.append(CellHolder.numberWithUnit(nu))
                }else{
                    self.cellHolders.append(CellHolder(string: "", attributes: self.cellAttributes))
                }
                geoIndex += 1
            }
        }
    }
}

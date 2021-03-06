//
//  LogDetailViewController.swift
//  FlightLog1000
//
//  Created by Brice Rosenzweig on 18/04/2022.
//

import UIKit
import OSLog
import RZUtils

class LogDetailViewController: UIViewController,ViewModelDelegate {
    var logFileOrganizer = FlightLogOrganizer.shared
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var fuelCollectionView: UICollectionView!
    @IBOutlet weak var legsCollectionView: UICollectionView!
    
    var flightLogFileInfo : FlightLogFileInfo? { return self.flightLogViewModel?.flightLogFileInfo }
    var legsDataSource : FlightLegsDataSource? = nil
    var fuelDataSource : FlightSummaryFuelDataSource? = nil
    var timeDataSource : FlightSummaryTimeDataSource? = nil
    
    var flightLogViewModel : FlightLogViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: .logFileInfoUpdated, object: nil, queue:nil){
            notification in
            DispatchQueue.main.async{
                self.updateUI()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func updateUI(){
        AppDelegate.worker.async {
            if self.flightLogFileInfo?.flightSummary != nil {
                DispatchQueue.main.async {
                    if self.name != nil {
                        self.name.text = self.flightLogFileInfo?.log_file_name
                        self.date.text = self.flightLogFileInfo?.start_time?.formatted()
                        
                        self.fuelDataSource = self.flightLogViewModel?.fuelDataSource
                        self.fuelCollectionView.dataSource = self.fuelDataSource
                        self.fuelCollectionView.delegate = self.fuelDataSource
                        if let tableCollectionLayout = self.fuelCollectionView.collectionViewLayout as? TableCollectionViewLayout {
                            tableCollectionLayout.tableCollectionDelegate = self.fuelDataSource
                        }else{
                            Logger.app.error("Internal error: Inconsistent layout ")
                        }
                        self.timeDataSource = self.flightLogViewModel?.timeDataSource
                        self.timeCollectionView.dataSource = self.timeDataSource
                        self.timeCollectionView.delegate = self.timeDataSource
                        if let tableCollectionLayout = self.timeCollectionView.collectionViewLayout as? TableCollectionViewLayout {
                            tableCollectionLayout.tableCollectionDelegate = self.timeDataSource
                        }else{
                            Logger.app.error("Internal error: Inconsistent layout ")
                        }
                    }
                    
                    self.view.setNeedsDisplay()
                    
                    if let legsDataSource = self.flightLogViewModel?.legsDataSource {
                        self.legsDataSource = legsDataSource
                        self.legsCollectionView.dataSource = self.legsDataSource
                        self.legsCollectionView.delegate = self.legsDataSource
                        if let tableCollectionLayout = self.legsCollectionView.collectionViewLayout as? TableCollectionViewLayout {
                            tableCollectionLayout.tableCollectionDelegate = self.legsDataSource
                        }else{
                            Logger.app.error("Internal error: Inconsistent layout ")
                        }
                    }else{
                        self.legsDataSource = nil
                    }
                }
            }
        }
    }

    private var progress : ProgressReport? = nil
    
    // MARK: - Handle updates
    
    func viewModelDidFinishBuilding(viewModel : FlightLogViewModel){
        self.progressView.isHidden = true
        self.updateUI()
    }
    
    func viewModelHasChanged(viewModel: FlightLogViewModel) {
        self.flightLogViewModel = viewModel
        
        if self.progress == nil {
            self.progress = ProgressReport(message: "LogDetail"){
                report in
                DispatchQueue.main.async {
                    if case .progressing(let val) = report.state {
                        self.progressView.setProgress( Float(val), animated: true )
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.updateUI()
            self.progressView.setProgress(0.0, animated: false)
            self.progressView.isHidden = false
        }
    }
}

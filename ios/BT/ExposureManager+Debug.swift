//
//  ExposureManager+Debug.swift
//  BT
//
//  Created by Emiliano Galitiello on 24/08/2020.
//  Copyright © 2020 Path Check Inc. All rights reserved.
//

import Foundation
import RealmSwift

protocol ExposureManagerDebuggable {
  func handleDebugAction(_ action: DebugAction,
                               resolve: @escaping RCTPromiseResolveBlock,
                               reject: @escaping RCTPromiseRejectBlock)
}

extension ExposureManager: ExposureManagerDebuggable {

  @objc func handleDebugAction(_ action: DebugAction,
                               resolve: @escaping RCTPromiseResolveBlock,
                               reject: @escaping RCTPromiseRejectBlock) {
    switch action {
    case .fetchDiagnosisKeys:
      manager.getDiagnosisKeys { (keys, error) in
        if let error = error {
          reject(error.localizedDescription, "Failed to get exposure keys", error)
        } else {
          resolve(keys!.map { $0.asDictionary })
        }
      }
    case .detectExposuresNow:
      guard btSecureStorage.userState.remainingDailyFileProcessingCapacity > 0 else {
        let hoursRemaining = 24 - Date.hourDifference(from: btSecureStorage.userState.dateLastPerformedFileCapacityReset ?? Date(),
                                                      to: Date())
        reject("Time window Error.",
               "You have reached the exposure file submission limit. Please wait \(hoursRemaining) hours before detecting exposures again.",
          GenericError.unknown)
        return
      }

      detectExposures { result in
        switch result {
        case .success(let numberOfFilesProcessed):
          resolve("Exposure detection successfully executed. Processed \(numberOfFilesProcessed) files.")
        case .failure(let exposureError):
          reject(exposureError.localizedDescription, exposureError.errorDescription, exposureError)
        }
      }
    case .simulateExposureDetectionError:
      btSecureStorage.exposureDetectionErrorLocalizedDescription = "Unable to connect to server."
      postExposureDetectionErrorNotification("Simulated Error")
      resolve(String.genericSuccess)
    case .simulateExposure:
      let exposure = Exposure(id: UUID().uuidString,
                              date: Date().posixRepresentation - Int(TimeInterval.random(in: 0...13)) * 24 * 60 * 60 * 1000)
      btSecureStorage.storeExposures([exposure])
      let content = UNMutableNotificationContent()
      content.title = String.newExposureNotificationTitle.localized
      content.body = String.newExposureNotificationBody.localized
      content.sound = .default
      let request = UNNotificationRequest(identifier: "identifier", content: content, trigger: nil)
      userNotificationCenter.add(request) { error in
        DispatchQueue.main.async {
          if let error = error {
            print("Error showing error user notification: \(error)")
          }
        }
      }
      resolve("Exposures: \(btSecureStorage.userState.exposures)")
    case .fetchExposures:
      resolve(currentExposures)
    case .resetExposures:
      btSecureStorage.exposures = List<Exposure>()
      resolve("Exposures: \(btSecureStorage.exposures.count)")
    case .toggleENAuthorization:
      let enabled = manager.exposureNotificationEnabled ? false : true
      requestExposureNotificationAuthorization(enabled: enabled) { result in
        resolve("EN Enabled: \(self.manager.exposureNotificationEnabled)")
      }
    case .showLastProcessedFilePath:
      let path = btSecureStorage.userState.urlOfMostRecentlyDetectedKeyFile
      resolve(path)
    }
  }
}

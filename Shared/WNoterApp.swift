//
//  WNoterApp.swift
//  Shared
//
//  Created by Floris Fredrikze on 25/09/2020.
//

import SwiftUI

@main
struct WNoterApp: App {
	var bluetoothReader: MMBluetoothReader

	init() {
		bluetoothReader = MMBluetoothReader()
	}

    var body: some Scene {
        WindowGroup {
			ContentView(bluetoothReader: bluetoothReader)
        }
    }
}

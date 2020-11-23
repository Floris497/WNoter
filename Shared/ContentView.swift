//
//  ContentView.swift
//  Shared
//
//  Created by Floris Fredrikze on 25/09/2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothReader: MMBluetoothReader
    
    var body: some View {
        #if os(macOS)
        TabView {
            MeasureView(bluetoothReader: bluetoothReader).tabItem {
                Image(systemName: "scalemass.fill")
                Text("Scale")
            }
            Spacer().tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }.padding()
        #elseif os(watchOS)
            MeasureView(bluetoothReader: bluetoothReader);  
        #else
        TabView {
            MeasureView(bluetoothReader: bluetoothReader).tabItem {
                Image(systemName: "scalemass.fill")
                Text("Scale")
            }
            Spacer().tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let blreader = MMBluetoothReader()
        ContentView(bluetoothReader: blreader).previewLayout(.sizeThatFits)
    }
}

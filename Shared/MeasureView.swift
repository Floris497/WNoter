//
//  MeasureView.swift
//  WNoter (iOS)
//
//  Created by Floris Fredrikze on 02/11/2020.
//

import SwiftUI
import HealthKit

#if os(watchOS)

struct MeasureView: View {
    @ObservedObject var bluetoothReader: MMBluetoothReader

    let healthStore = HKHealthStore.init()
    
    var body: some View {
        HStack {
            if  bluetoothReader.isUpdating {
                Button(action: {
                    bluetoothReader.stopScanning()
                }, label: {
                    Text("Stop Scanning").foregroundColor(.red)
                })
            } else {
                Button(action: {
                    bluetoothReader.startScanning()
                }, label: {
                    Text("Start Scanning")
                })
            }
        }
    }
}

#else

struct HealthValueView: View {
    var prefix: String?
    var value: String
    var unit: String
    
    var buttonTitle: String?
    var buttonIcon: Image?
    var buttonAction: (() -> Void)?
    
    @ScaledMetric var size: CGFloat = 1
    
    @ViewBuilder var body: some View {
        HStack {
            if let str = prefix {
                Text(str).font(.system(size: 24 * size, weight: .bold, design: .rounded))
                Spacer()
            }
            Text(value).font(.system(size: 24 * size, weight: .bold, design: .rounded))
                + Text(" \(unit)").font(.system(size: 14 * size, weight: .semibold, design: .rounded)).foregroundColor(.secondary)
            if let buttonAction = buttonAction {
                Spacer()
                Button("\(buttonTitle ?? "Default")", action: buttonAction)
            }
        }
    }
}

struct CustomGroupBoxStyle<V: View>: GroupBoxStyle {
    var color: Color
    var destination: V
    var date: Date?
    
    @ScaledMetric var size: CGFloat = 1
    
    func makeBody(configuration: Configuration) -> some View {
        GroupBox(label: HStack {
            configuration.label.foregroundColor(color)
            if date != nil {
                Text("\(date!)").font(.footnote).foregroundColor(.secondary).padding(.trailing, 4)
            }
        }) {
            configuration.content.padding(.top)
        }
    }
}

struct MeasureView: View {
    @ObservedObject var bluetoothReader: MMBluetoothReader
    
    let healthStore = HKHealthStore.init()
    
    //    NSSet<HKSampleType *> *shareSet = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], nil];
    //    [healthStore requestAuthorizationToShareTypes:shareSet readTypes:nil completion:^(BOOL success, NSError * _Nullable error) {}];
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 16 ) {
                GroupBox {
                    HStack {
                        Spacer()
                        if  bluetoothReader.isUpdating {
                            Button(action: {
                                bluetoothReader.stopScanning()
                            }, label: {
                                Text("Stop Scanning").foregroundColor(.red)
                            })
                        } else {
                            Button(action: {
                                bluetoothReader.startScanning()
                            }, label: {
                                Text("Start Scanning")
                            })
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                GroupBox {
                    HStack {
                        if let item = bluetoothReader.wdata.first(where: { $0.type == .kTempWeight}), item.weight != 0
                        {
                            HealthValueView(prefix: "Measuring: ",
                                            value: String(format: "%.2f", Double(item.weight) / 1000.0),
                                            unit: "kg")
                        }
                        else {
                            Spacer()
                            HealthValueView(value: "Not Measuring", unit: "")
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                Divider()
            }
            .padding(.top)

            if let definite = bluetoothReader.wdata.filter {$0.type == .kDefiniteWeight}, definite.count > 0
            {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(definite , id: \.id) { item in
                            GroupBox(content: {
                                HStack (spacing: 5) {
                                    HealthValueView(value: String(format: "%.2f", Double(item.weight) / 1000.0), unit: "kg", buttonTitle: "Add")
                                    {
                                        let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMass)
                                        let quantity = HKQuantity.init(unit: .gram(), doubleValue: Double(item.weight))

                                        guard (quantityType != nil)
                                        else {
                                            return
                                        }
                                        
                                        
                                        let sample = HKQuantitySample.init(type: quantityType!, quantity: quantity, start: item.date, end: item.date)
                                        
                                        healthStore.requestAuthorization(toShare: [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!], read: nil) { (success, error) in
                                            if success
                                            {
                                                healthStore.save(sample) { (success, error) in
                                                    if !success
                                                    {
                                                        NSLog("Did not save uuuuf");
                                                    }
                                                }
                                            }
                                        }
                                        
                                        NSLog("Pressed button for \(item.weight)")
                                    }
                                    Spacer()
                                }
                            })
                            .animation(.easeIn)
                        }
                    }
                    .padding()
                    .transition(AnyTransition.scale)
                }
            }
            else {
                Spacer()
                Text("No Data").foregroundColor(.gray)
                Spacer()
            }
        }
        .navigationTitle("WNoter")
    }
}

#endif

struct MeasureView_Previews: PreviewProvider {
    static var previews: some View {
        let blreader = MMBluetoothReader()
        MeasureView(bluetoothReader: blreader).previewLayout(.sizeThatFits)
    }
}

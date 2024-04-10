//
//  ContentView.swift
//  BetterRest
//
//  Created by csuftitan on 2/26/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                Section("Desired amount of sleep"){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

//                Section("Daily coffee intake") {
//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
//                }
                Section("Daily coffee intake") {
                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text(String($0))
                        }
                    }
                }
                Text(calculateBedtime)
                    .font(.title3)
            }
            .navigationTitle("BetterRest")
        }
    }

    var calculateBedtime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep

            return "Your ideal bedtime is "  + sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
}

#Preview {
    ContentView()
}

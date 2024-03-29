//
//  ContentView.swift
//  BetterRest
//
//  Created by Fernando Gomez on 1/12/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = "Your ideal bedtime is..."
    @State private var alertMessage = "10:38 PM"
    @State private var showingAlert = false

   static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from:components) ?? Date.now
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                
                Section {
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: wakeUp) { _ in
                        print(wakeUp)
                        calculateBedtime()
                    }
            }
            
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25).onChange(of: sleepAmount) { _ in
                        print(sleepAmount)
                        calculateBedtime()
                    }
                    
                }
                
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("Number of Cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0)")
                        }
                    }.onChange(of: coffeeAmount) { _ in
                        print(coffeeAmount)
                        calculateBedtime()
                    }
                
                }
                
                Section {
 
                    Text(alertTitle).font(.title)
                    Text(alertMessage).font(.largeTitle).fontWeight(.heavy).foregroundColor(.cyan)
                }
                
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("OK") {}
//
//                } message: {
//                    Text(alertMessage)
//
//                }
                
            }
            
        }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = components.hour ?? 0
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
//            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

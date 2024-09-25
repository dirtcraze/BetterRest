import CoreML
import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var wakeUpTime = Self.defaultWakeTime
    @State private var sleepHours = 8.0
    @State private var cupsOfCoffee = 1
    
    var test: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let predictions = try model.prediction(wake: Double(hours+minutes), estimatedSleep: sleepHours, coffee: Double(cupsOfCoffee))
            
            let sleepTime = wakeUpTime - predictions.actualSleep
            
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return "error"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                VStack (alignment: .leading) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Wake Up Time", selection: $wakeUpTime, displayedComponents: .hourAndMinute).labelsHidden()
                }
                VStack (alignment: .leading){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepHours.formatted()) hours", value: $sleepHours, in: 4...12, step: 0.25)
                }
                
                VStack (alignment: .leading) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper(cupsOfCoffee == 1 ? "1 cup" : "\(cupsOfCoffee.formatted()) cups", value: $cupsOfCoffee, in: 1...20, step: 1)
                }
                
                VStack {
                    Text("Your ideal bedtime is…")
                    Text("\(test)")
                        .font(.title.weight(.bold))
            }
            .navigationTitle("BetterRest")
            
                    
            }
        }
    }
}

#Preview {
    ContentView()
}

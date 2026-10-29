import SwiftUI

struct ContentView: View {
    @AppStorage("dailyGoal") private var dailyGoal = 2500
    @AppStorage("consumedWater") private var consumedWater = 0
    @AppStorage("trackingDay") private var trackingDay = ""
    @Environment(\.scenePhase) private var scenePhase

    private var progress: Double {
        min(Double(consumedWater) / Double(max(dailyGoal, 1)), 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    ZStack {
                        Circle().stroke(.blue.opacity(0.15), lineWidth: 20)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 8) {
                            Image(systemName: "drop.fill")
                                .font(.largeTitle).foregroundStyle(.blue)
                            Text("\(consumedWater) ml").font(.largeTitle.bold())
                            Text("z \(dailyGoal) ml").foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 250, height: 250)
                    .padding(.top, 20)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Wypito \(consumedWater) z \(dailyGoal) mililitrów")

                    Text(consumedWater >= dailyGoal ? "Dzienny cel osiągnięty!" : "Czas na łyk wody")
                        .font(.title2.bold())

                    HStack(spacing: 12) {
                        ForEach([150, 250, 500], id: \.self) { amount in
                            Button {
                                refreshDay()
                                withAnimation { consumedWater += amount }
                            } label: {
                                Text("+\(amount) ml")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityLabel("Dodaj \(amount) mililitrów wody")
                        }
                    }

                    GroupBox("Twój dzienny cel") {
                        Stepper("\(dailyGoal) ml", value: $dailyGoal, in: 500...5000, step: 250)
                            .padding(.vertical, 8)
                    }
                    Text("Ustaw cel odpowiedni dla siebie. Potrzeby nawodnienia są indywidualne.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .navigationTitle("DrinkWater")
        }
        .onAppear(perform: refreshDay)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshDay() }
        }
        .task {
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(30)) }
                catch { return }
                refreshDay()
            }
        }
    }

    private func refreshDay() {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let today = "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
        guard trackingDay != today else { return }
        consumedWater = 0
        trackingDay = today
    }
}

#Preview { ContentView() }

import SwiftUI

struct ContentView: View {
    @AppStorage("dailyGoal") private var dailyGoal = 2500
    @AppStorage("consumedWater") private var consumedWater = 0
    @AppStorage("trackingDay") private var trackingDay = ""
    @AppStorage("lastWaterAmount") private var lastWaterAmount = 0
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var reminders = WaterReminders()
    @Environment(\.openURL) private var openURL
    @State private var showingGoal = false
    @State private var feedbackTrigger = 0
    @ScaledMetric private var ringSize = 240

    private var remaining: Int { max(dailyGoal - consumedWater, 0) }
    private var progress: Double {
        min(Double(consumedWater) / Double(max(dailyGoal, 1)), 1)
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    progressCard
                    quickAdd
                    if lastWaterAmount > 0 {
                        Button(action: undoLastEntry) {
                            Label("Cofnij ostatnie dodanie", systemImage: "arrow.uturn.backward")
                                .font(.subheadline)
                                .frame(minHeight: 44)
                        }
                    }
                    remindersCard
                    goalCard
                    Text("Każdy łyk się liczy. Ustaw cel odpowiedni dla siebie — potrzeby nawodnienia są indywidualne.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("DrinkWater")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingGoal) { goalSheet }
        }
        .tint(.cyan)
        .sensoryFeedback(.success, trigger: feedbackTrigger)
        .onAppear(perform: refreshDay)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                refreshDay()
                Task { await reminders.refresh() }
            }
        }
        .task {
            await reminders.refresh()
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(30)) }
                catch { return }
                refreshDay()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline).foregroundStyle(.secondary)
            Text("Zadbaj o swoje nawodnienie")
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressCard: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle().stroke(.cyan.opacity(0.12), lineWidth: 18)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(colors: [.cyan, .blue, .cyan], center: .center),
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 6) {
                    Image(systemName: remaining == 0 ? "checkmark.circle.fill" : "drop.fill")
                        .font(.title).foregroundStyle(.cyan)
                    Text("\(consumedWater)").font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .contentTransition(.numericText())
                    Text("z \(dailyGoal) ml").font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(24)
                .minimumScaleFactor(0.7)
            }
            .frame(width: min(ringSize, 280), height: min(ringSize, 280))
            .padding(10)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Wypito \(consumedWater) z \(dailyGoal) mililitrów. Pozostało \(remaining) mililitrów.")
            VStack(spacing: 5) {
                Text(remaining == 0 ? "Cel osiągnięty!" : "Jeszcze \(remaining) ml do celu")
                    .font(.headline)
                Text(remaining == 0 ? "Świetna robota na dziś." : "Małe łyki, dobry nawyk.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 28))
    }

    private var quickAdd: some View {
        Button { addWater(250) } label: {
            Label("Wypiłem szklankę", systemImage: "mug.fill")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 60)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityHint("Dodaje jedną szklankę, czyli 250 mililitrów wody")
    }

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { reminders.isEnabled },
                set: { enabled in Task { await reminders.setEnabled(enabled) } }
            )) {
                Label("Przypomnienia co 2 godziny", systemImage: "bell.badge.fill")
                    .font(.headline)
            }
            .disabled(reminders.isBusy)
            Text("Codziennie: 8:00, 10:00, 12:00, 14:00, 16:00, 18:00, 20:00 i 22:00. W nocy cisza.")
                .font(.footnote).foregroundStyle(.secondary)
            if reminders.isBusy {
                ProgressView("Ustawianie przypomnień…")
                    .font(.footnote)
            }
            if let message = reminders.message {
                Text(message).font(.footnote).foregroundStyle(.secondary)
                    .accessibilityLabel(message)
            }
            if reminders.needsSettings {
                Button("Otwórz ustawienia powiadomień") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .frame(minHeight: 44)
            }
            Text("Dźwięk zależy od ustawień iPhone’a, trybu cichego i trybu skupienia.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var goalCard: some View {
        Button { showingGoal = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "target").font(.title2).foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dzienny cel").font(.subheadline).foregroundStyle(.secondary)
                    Text("\(dailyGoal) ml").font(.headline)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Zmień dzienny cel nawodnienia")
    }

    private var goalSheet: some View {
        NavigationStack {
            Form {
                Section("Twój cel") {
                    Stepper("\(dailyGoal) ml", value: $dailyGoal, in: 500...5000, step: 250)
                }
                Section {
                    Text("Dopasuj cel do swoich potrzeb i zaleceń lekarza. Zmiana celu nie usuwa wypitej dziś wody.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Dzienny cel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") { showingGoal = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func addWater(_ amount: Int) {
        refreshDay()
        withAnimation(.easeInOut(duration: 0.3)) {
            consumedWater += amount
            lastWaterAmount = amount
        }
        feedbackTrigger += 1
    }

    private func undoLastEntry() {
        refreshDay()
        guard lastWaterAmount > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            consumedWater = max(consumedWater - lastWaterAmount, 0)
            lastWaterAmount = 0
        }
    }

    private func refreshDay() {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let today = "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
        guard trackingDay != today else { return }
        consumedWater = 0
        lastWaterAmount = 0
        trackingDay = today
    }
}

#Preview { ContentView() }

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var zones: [Zone] = []
    @State private var showingAddZone = false
    @State private var isConnected = false

    var body: some View {
        NavigationView {
            List {
                Section("Status") {
                    HStack {
                        Circle()
                            .fill(isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(isConnected ? "Connected" : "Disconnected")
                        Spacer()
                        Text(locationManager.authorizationStatus == .authorizedAlways ? "📍 Always" :
                                locationManager.authorizationStatus == .authorizedWhenInUse ? "📍 When in use" : "📍 No permission")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    LabeledContent("Device ID", value: locationManager.deviceID)
                        .font(.caption)
                    LabeledContent("Last coordinate", value: locationManager.lastKnownCoordinate)
                        .font(.caption)
                    LabeledContent("Post status", value: locationManager.lastPostStatus)
                        .font(.caption)
                    LabeledContent("Monitoring", value: locationManager.monitoredRegionNames.isEmpty ? "No regions" : locationManager.monitoredRegionNames.joined(separator: ", "))
                        .font(.caption)

                    if let currentZone = locationManager.currentZone {
                        Text("Current zone: \(currentZone)")
                            .font(.subheadline)
                    }

                    if locationManager.lastEvent != "None" {
                        Text(locationManager.lastEvent)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Button(locationManager.isSyncingCurrentZone ? "Syncing…" : "Sync current location") {
                        locationManager.syncCurrentZone()
                    }
                    .disabled(locationManager.isSyncingCurrentZone || !isConnected)

                    Button("Send test event") {
                        locationManager.sendTestEvent()
                    }
                    .disabled(!isConnected)
                }

                Section("Monitored Zones (\(zones.count))") {
                    if zones.isEmpty {
                        Text("No zones yet. Add one to get started.")
                            .foregroundColor(.secondary)
                    }
                    ForEach(zones) { zone in
                        VStack(alignment: .leading) {
                            Text(zone.name).font(.headline)
                            Text(String(format: "%.4f, %.4f — %.0fm", zone.lat, zone.long, zone.radius))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            let zone = zones[i]
                            API.shared.deleteZone(name: zone.name) { _ in
                                loadZones()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Location Warden")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddZone = true }) {
                        Label("Add Zone", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddZone) {
                AddZoneView { zone in
                    API.shared.createZone(zone) { success in
                        if success { loadZones() }
                    }
                }
            }
            .onAppear { connect() }
            .refreshable { loadZones() }
        }
    }

    func connect() {
        API.shared.authenticate(serverURL: "https://arch.projectveritos.com") { ok in
            isConnected = ok
            if ok {
                locationManager.requestPermission()
                loadZones()
            }
        }
    }

    func loadZones() {
        API.shared.fetchZones { result in
            if case .success(let z) = result {
                zones = z
                locationManager.startMonitoring(zones: z)
            }
        }
    }
}

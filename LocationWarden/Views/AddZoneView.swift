import SwiftUI
import MapKit
import CoreLocation

struct AddZoneView: View {
    let onAdd: (Zone) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var radius: Double = 200
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var pinLocation: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Map with crosshair overlay
                ZStack(alignment: .center) {
                    Map(position: $position) {
                        if let pin = pinLocation {
                            Annotation("Zone", coordinate: pin) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                            }
                            MapCircle(center: pin, radius: CLLocationDistance(radius))
                                .foregroundStyle(.red.opacity(0.15))
                        }
                        UserAnnotation()
                    }

                    // Crosshair
                    if pinLocation == nil {
                        Image(systemName: "crosshair")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.red)
                            .shadow(color: .white, radius: 2)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 280)
                .onMapCameraChange(frequency: .onEnd) { context in
                    if pinLocation == nil {
                        coordinate = context.camera.centerCoordinate
                    }
                }

                // Coordinates display
                Text(String(format: "%.4f, %.4f", pinLocation?.latitude ?? coordinate.latitude, pinLocation?.longitude ?? coordinate.longitude))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                // Form fields below map
                Form {
                    Section("Zone") {
                        TextField("Name (e.g. Gym)", text: $name)
                        VStack(alignment: .leading) {
                            Text("Radius: \(Int(radius))m")
                            Slider(value: $radius, in: 50...1000, step: 25)
                        }
                    }

                    Section {
                        if pinLocation == nil {
                            Button("Drop Pin Here") {
                                pinLocation = coordinate
                            }
                        } else {
                            Button("Move Pin") {
                                pinLocation = nil
                            }
                            .foregroundColor(.orange)
                        }

                        Button("Add Zone") {
                            let finalCoord = pinLocation ?? coordinate
                            let zone = Zone(name: name, lat: finalCoord.latitude, long: finalCoord.longitude, radius: radius)
                            onAdd(zone)
                            dismiss()
                        }
                        .disabled(name.isEmpty || pinLocation == nil)
                    }
                }
            }
            .navigationTitle("Add Zone")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let loc = CLLocationManager().location?.coordinate {
                    coordinate = loc
                    position = .camera(MapCamera(centerCoordinate: loc, distance: 1200))
                }
            }
        }
    }
}

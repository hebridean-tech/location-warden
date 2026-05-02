import SwiftUI
import MapKit
import CoreLocation

struct AddZoneView: View {
    let existingZone: Zone?
    let onSave: (Zone) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var radius: Double = 200
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var pinLocation: CLLocationCoordinate2D?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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

                Text(String(format: "%.4f, %.4f", pinLocation?.latitude ?? coordinate.latitude, pinLocation?.longitude ?? coordinate.longitude))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

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

                        Button(existingZone == nil ? "Add Zone" : "Save Zone") {
                            let finalCoord = pinLocation ?? coordinate
                            let zone = Zone(name: name, lat: finalCoord.latitude, long: finalCoord.longitude, radius: radius)
                            onSave(zone)
                            dismiss()
                        }
                        .disabled(name.isEmpty || pinLocation == nil)
                    }
                }
            }
            .navigationTitle(existingZone == nil ? "Add Zone" : "Edit Zone")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let existingZone {
                    let existingCoordinate = CLLocationCoordinate2D(latitude: existingZone.lat, longitude: existingZone.long)
                    name = existingZone.name
                    radius = existingZone.radius
                    coordinate = existingCoordinate
                    pinLocation = existingCoordinate
                    position = .camera(MapCamera(centerCoordinate: existingCoordinate, distance: max(radius * 4, 500)))
                } else if let loc = CLLocationManager().location?.coordinate {
                    coordinate = loc
                    position = .camera(MapCamera(centerCoordinate: loc, distance: 1200))
                }
            }
        }
    }
}

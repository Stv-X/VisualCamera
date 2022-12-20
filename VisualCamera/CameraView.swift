import SwiftUI
import Network
import UniformTypeIdentifiers

struct CameraView: View {
    @StateObject private var model = DataModel()
    
    private static let barHeightFactor = 0.15
    
    @State private var isOptionsModalPresented = false
    @State private var options = CameraOptions()
    
    @State private var optionsToChange = CameraOptions()
    
    @State private var hostToChange = ""
    @State private var portToChange = ""
    @State private var durationToChange = 10
    @State private var selectedEncodingFormatToChange = UTType.jpeg

    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(image: $model.viewfinderImage)
                    .overlay(alignment: .top) {
                        topButtonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.thinMaterial)
                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.thinMaterial)
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
            .task {
                await model.camera.start()
                await model.loadPhotos()
                await model.loadThumbnail()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
    
    private var CameraOptionsModalView: some View {
        NavigationStack {
            List {
                Section("Server to connect") {
                    HStack {
                        Text("Host")
                        Spacer()
                        TextField("host", text: $hostToChange)
                            .frame(width: 180)
                    }
                    
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("port", text: $portToChange)
                            .frame(width: 180)
                    }
                }
                
                Section("Duration") {
                    HStack {
                        Text("\(durationToChange)s")
                        Spacer()
                        Stepper("", value: $durationToChange, in: 1...30)
                            .frame(width: 180)
                    }
                }
                
                Section("Media") {
                    HStack {
                        Text("Image Format")
                        Spacer()
                        Picker("Image Format", selection: $selectedEncodingFormatToChange) {
                            Text("JPEG").tag(UTType.jpeg)
                            Text("PNG").tag(UTType.png)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton
                }
            }
            .navigationTitle("Settings")
            
        }
        .onAppear {
            optionsToChange = options
            hostToChange = "\(optionsToChange.host)"
            portToChange = "\(optionsToChange.port)"
            durationToChange = optionsToChange.duration
            selectedEncodingFormatToChange = model.camera.imageEncodingFormat
        }
        .frame(minWidth: 360, minHeight: 500)
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            self.isOptionsModalPresented = false
        }
    }
    private var confirmButton: some View {
        Button("Confirm") {
            optionsToChange.host = NWEndpoint.Host(hostToChange)
            optionsToChange.port = NWEndpoint.Port(portToChange)!
            optionsToChange.imageEncodingFormat = selectedEncodingFormatToChange
            optionsToChange.duration = durationToChange
            
            options = optionsToChange
            
            model.camera.imageEncodingFormat = options.imageEncodingFormat

            self.isOptionsModalPresented = false
        }
    }
    
    private func topButtonsView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Client")
                    .font(.title)
                    .bold()
                if wifiIP != nil {
                    Text(wifiIP!)
                }
            }
            Spacer()
            Button {
                isOptionsModalPresented = true
            } label: {
                Label("Options", systemImage: "gear")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .popover(isPresented: $isOptionsModalPresented) {
                CameraOptionsModalView
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
    
    private func buttonsView() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Button {
                    model.camera.takePhoto()
                    print(model.camera.imageEncodingFormat)
                } label: {
                    Label {
                        Text("Take Photo")
                    } icon: {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 3)
                                .frame(width: 62, height: 62)
                            Circle()
                                .fill(.white)
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                
                Spacer()
            }
            
            HStack {
//                NavigationLink {
//                    PhotoCollectionView(photoCollection: model.photoCollection)
//                        .onAppear {
//                            model.camera.isPreviewPaused = true
//                        }
//                        .onDisappear {
//                            model.camera.isPreviewPaused = false
//                        }
//                } label: {
//                    Label {
//                        Text("Gallery")
//                    } icon: {
//                        ThumbnailView(image: model.thumbnailImage)
//                    }
//                }
                
                Spacer()
                
                Button {
                    model.camera.switchCaptureDevice()
                } label: {
                    Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
}




struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

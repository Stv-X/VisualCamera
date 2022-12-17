import SwiftUI
import Network

struct CameraView: View {
    @StateObject private var model = DataModel()
    
    private static let barHeightFactor = 0.15
    
    @State private var isOptionsModalPresented = false
    @State private var options = CameraOptions()
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(image: $model.viewfinderImage)
                    .overlay(alignment: .top) {
                        topButtonView()
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
        .sheet(isPresented: $isOptionsModalPresented) {
            CameraOptionsModalView(isPresented: $isOptionsModalPresented, options: $options)
        }
    }
    
    private func topButtonView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            Button {
                isOptionsModalPresented = true
            } label: {
                Label("Options", systemImage: "gear")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            
            NavigationLink {
                PhotoCollectionView(photoCollection: model.photoCollection)
                    .onAppear {
                        model.camera.isPreviewPaused = true
                    }
                    .onDisappear {
                        model.camera.isPreviewPaused = false
                    }
            } label: {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: model.thumbnailImage)
                }
            }
            
            Button {
                model.camera.takePhoto()
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
            
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
}

struct CameraOptionsModalView: View {
    @State private var optionsToChange = CameraOptions()
    @State private var hostText = ""
    @State private var portText = ""
    
    @Binding var isPresented: Bool
    @Binding var options: CameraOptions
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Host")
                    Spacer()
                    TextField("host", text: $hostText)
                        .frame(width: 200)
                }
                HStack {
                    Text("Port")
                    Spacer()
                    TextField("port", text: $portText)
                        .frame(width: 200)
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
            hostText = "\(optionsToChange.host)"
            portText = "\(optionsToChange.port)"
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            self.isPresented = false
        }
    }
    private var confirmButton: some View {
        Button("Confirm") {
            optionsToChange.host = NWEndpoint.Host(hostText)
            optionsToChange.port = NWEndpoint.Port(portText)!
            options = optionsToChange
            self.isPresented = false
        }
    }
}

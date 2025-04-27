import SwiftUI

struct ContentView: View {
    @StateObject var usbWatcher = USBWatcher()

    var body: some View {
        NavigationView {
            List(usbWatcher.mountedVolumes, id: \.self) { volume in
                VStack(alignment: .leading) {
                    Text(volume)
                        .font(.headline)
                    Text("Status: Mounted")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("USB Devices")
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

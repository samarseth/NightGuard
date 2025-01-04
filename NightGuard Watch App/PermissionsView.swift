import SwiftUI

struct PermissionsView: View {
    @StateObject private var permissionsManager = PermissionsManager()
    @Binding var showPermissions: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to NightGuard")
                .font(.title3)
                .bold()
            
            Text("We need a few permissions to help monitor your sleep position")
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 15) {
                PermissionRow(
                    title: "Motion",
                    description: "To detect your sleep position",
                    iconName: "figure.walk",
                    isAuthorized: permissionsManager.motionAuthorized
                )
                
                PermissionRow(
                    title: "Health",
                    description: "To save your sleep data",
                    iconName: "heart.fill",
                    isAuthorized: permissionsManager.healthAuthorized
                )
            }
            .padding()
            
            Button(action: {
                Task {
                    await permissionsManager.requestPermissions()
                    showPermissions = false
                }
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let iconName: String
    let isAuthorized: Bool
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.blue)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: isAuthorized ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isAuthorized ? .green : .gray)
        }
    }
}

#Preview {
    PermissionsView(showPermissions: .constant(true))
}
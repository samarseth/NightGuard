import SwiftUI

struct PermissionsView: View {
    @StateObject private var permissionsManager = PermissionsManager()
    @Binding var showPermissions: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Welcome to NightGuard")
                    .font(.system(.headline))
                    .padding(.top, 5)
                
                Text("We need permissions to monitor your sleep position")
                    .font(.system(.caption))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
                
                VStack(alignment: .leading, spacing: 10) {
                    PermissionRow(
                        title: "Motion",
                        description: "To detect position",
                        iconName: "figure.walk",
                        isAuthorized: permissionsManager.motionAuthorized
                    )
                    
                    PermissionRow(
                        title: "Health",
                        description: "To save data",
                        iconName: "heart.fill",
                        isAuthorized: permissionsManager.healthAuthorized
                    )
                }
                .padding(.vertical, 5)
                
                Button(action: {
                    Task {
                        await permissionsManager.requestPermissions()
                        showPermissions = false
                    }
                }) {
                    Text("Continue")
                        .font(.system(.body))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)
            }
            .padding(10)
        }
    }
}

struct PermissionRow: View {
    let title: String
    let description: String
    let iconName: String
    let isAuthorized: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(.blue)
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.footnote))
                Text(description)
                    .font(.system(.caption2))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: isAuthorized ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isAuthorized ? .green : .gray)
                .font(.system(size: 16))
        }
    }
}

#Preview {
    PermissionsView(showPermissions: .constant(true))
}

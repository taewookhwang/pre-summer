#!/bin/bash

# This script creates a minimal buildable version of the app by:
# 1. Creating stubs for problematic files
# 2. Using custom build settings to exclude problematic components
# 3. Cleaning and building the app with these settings

echo "🔄 Starting minimal app build process..."

# Create a timestamp for backup directory
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./temp_backups_${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

# Record current directory
ORIG_DIR=$(pwd)

# List of problematic files/directories
PROBLEM_FILES=(
  "Analytics/Events"
  "Analytics/AnalyticsManager.swift"
  "ViewModel/Admin"
  "ViewModel/Chat"
  "Network/WebSocket/AdminDashboardSocket.swift"
  "State/Consumer/PaymentState.swift"
)

echo "📦 Backing up problematic files..."

# Backup problematic files
for file in "${PROBLEM_FILES[@]}"; do
  if [ -e "$file" ]; then
    dir=$(dirname "$file")
    mkdir -p "$BACKUP_DIR/$dir"
    
    echo "  - Backing up $file"
    if [ -d "$file" ]; then
      # It's a directory, copy the entire directory
      cp -R "$file" "$BACKUP_DIR/$file"
    else
      # It's a file, copy the file
      cp "$file" "$BACKUP_DIR/$file"
    fi
  fi
done

echo "🧩 Creating minimal implementations..."

# Create minimal implementations
mkdir -p Analytics/Events
mkdir -p ViewModel/Admin
mkdir -p ViewModel/Chat
mkdir -p State/Consumer

# Create minimal AnalyticsManager
cat > Analytics/AnalyticsManager.swift << 'EOF'
import Foundation

class AnalyticsManager {
    private static let shared = AnalyticsManager()
    private init() {}
    
    static func configure(with logger: Any) {}
    static func trackEvent(_ event: Any) {}
    static func trackConsumerEvent(_ event: Any) {}
    static func trackTechnicianEvent(_ event: Any) {}
    static func trackBusinessEvent(_ event: Any) {}
}
EOF

# Create minimal Analytics events
cat > Analytics/Events/AnalyticsEvent.swift << 'EOF'
import Foundation

protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any] { get }
    var category: String { get }
}

enum EventCategory: String {
    case consumer = "consumer"
    case technician = "technician"
    case business = "business"
    case system = "system"
}
EOF

cat > Analytics/Events/BusinessEvents.swift << 'EOF'
import Foundation

protocol BusinessEvent: AnalyticsEvent {}
EOF

cat > Analytics/Events/ConsumerEvents.swift << 'EOF'
import Foundation

protocol ConsumerEvent: AnalyticsEvent {}
EOF

cat > Analytics/Events/TechnicianEvents.swift << 'EOF'
import Foundation

protocol TechnicianEvent: AnalyticsEvent {}
EOF

# Create minimal AdminDashboardSocket
cat > Network/WebSocket/AdminDashboardSocket.swift << 'EOF'
import Foundation

class AdminDashboardSocket {
    static let shared = AdminDashboardSocket()
    
    var onJobUpdate: (([Any]) -> Void)?
    var onLocationUpdate: ((Int, (latitude: Double, longitude: Double)) -> Void)?
    var onDisconnect: (() -> Void)?
    
    private init() {}
    
    func connect(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    func disconnect() {}
}
EOF

# Create minimal Admin ViewModels
cat > ViewModel/Admin/DashboardViewModel.swift << 'EOF'
import Foundation

class DashboardViewModel {
    enum ViewState {
        case idle, loading, loaded, error(String)
    }
    
    private(set) var state: ViewState = .idle
    var stateDidChange: (() -> Void)?
    var dataDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    func loadDashboardData() {}
}
EOF

cat > ViewModel/Admin/MatchingViewModel.swift << 'EOF'
import Foundation

class MatchingViewModel {
    enum ViewState {
        case idle, loading, loaded, error(String)
    }
    
    private(set) var state: ViewState = .idle
    var stateDidChange: (() -> Void)?
}
EOF

cat > ViewModel/Admin/RealtimeMonitorViewModel.swift << 'EOF'
import Foundation

class RealtimeMonitorViewModel {
    enum ViewState {
        case idle, loading, loaded, error(String)
    }
    
    private(set) var state: ViewState = .idle
    var stateDidChange: (() -> Void)?
}
EOF

cat > ViewModel/Admin/UserManagementViewModel.swift << 'EOF'
import Foundation

class UserManagementViewModel {
    enum ViewState {
        case idle, loading, loaded, error(String)
    }
    
    private(set) var state: ViewState = .idle
    var stateDidChange: (() -> Void)?
}
EOF

# Create minimal Chat ViewModels
cat > ViewModel/Chat/ChatListViewModel.swift << 'EOF'
import Foundation

class ChatListViewModel {
    enum ViewState {
        case idle, loading, loaded, error(String)
    }
    
    private(set) var state: ViewState = .idle
    var stateDidChange: (() -> Void)?
}
EOF

cat > ViewModel/Chat/ChatRoomViewModel.swift << 'EOF'
import Foundation

class ChatRoomViewModel {
    enum ViewState {
        case idle, loading, loaded, error(String)
    }
    
    private(set) var state: ViewState = .idle
    var stateDidChange: (() -> Void)?
}
EOF

# Create minimal PaymentState
cat > State/Consumer/PaymentState.swift << 'EOF'
import Foundation

class PaymentState {
    enum Status {
        case idle, loading, completed, error(String)
    }
    
    private(set) var status: Status = .idle
    var statusDidChange: (() -> Void)?
}
EOF

# Create custom xcconfig file
cat > ./touch/minimal_build.xcconfig << 'EOF'
// Custom build settings to exclude problematic files
#include "Pods/Target Support Files/Pods-HomeCleaningApp/Pods-HomeCleaningApp.debug.xcconfig"

// Optimize build for fastest compilation
SWIFT_OPTIMIZATION_LEVEL = -Onone
GCC_OPTIMIZATION_LEVEL = 0
DEBUG_INFORMATION_FORMAT = dwarf
SWIFT_COMPILATION_MODE = singlefile

// Increase timeouts
LINK_TIMELIMIT = 120

// Reduce warnings
GCC_WARN_INHIBIT_ALL_WARNINGS = YES
SWIFT_SUPPRESS_WARNINGS = YES

// Make sure iOS version matches pods requirement
IPHONEOS_DEPLOYMENT_TARGET = 18.2

// Disable features to speed up build
DEAD_CODE_STRIPPING = NO
ENABLE_STRICT_OBJC_MSGSEND = NO

// Skip some validation steps
VALIDATE_PRODUCT = NO
EOF

echo "🛠️ Building minimal app..."

# Create build command script
cat > ./touch/run_build.sh << 'EOF'
#!/bin/bash

# Clean and build using custom config
xcodebuild clean build \
  -project HomeCleaningApp.xcodeproj \
  -scheme HomeCleaningApp \
  -configuration Debug \
  -xcconfig ./touch/minimal_build.xcconfig \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=18.2' \
  EXCLUDED_SOURCE_FILE_NAMES="**/ViewModel/Admin/* **/ViewModel/Chat/* **/Analytics/Events/* **/Network/WebSocket/AdminDashboardSocket.swift" \
  CLANG_ENABLE_MODULES=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_ALLOWED=NO
EOF

chmod +x ./touch/run_build.sh

# Create restore script
cat > ./touch/restore_files.sh << EOF
#!/bin/bash

# Restore original files from backup
echo "Restoring files from backup: $BACKUP_DIR"

# List of backed up files/directories
BACKED_UP_FILES=(
  "Analytics/Events"
  "Analytics/AnalyticsManager.swift"
  "ViewModel/Admin"
  "ViewModel/Chat"
  "Network/WebSocket/AdminDashboardSocket.swift"
  "State/Consumer/PaymentState.swift"
)

# Restore from backup
for file in "\${BACKED_UP_FILES[@]}"; do
  if [ -e "$BACKUP_DIR/\$file" ]; then
    echo "  - Restoring \$file"
    
    # Remove stub implementation
    rm -rf "\$file"
    
    # Restore from backup
    if [ -d "$BACKUP_DIR/\$file" ]; then
      # It's a directory
      cp -R "$BACKUP_DIR/\$file" "\$(dirname "\$file")/"
    else
      # It's a file
      cp "$BACKUP_DIR/\$file" "\$file"
    fi
  fi
done

echo "✅ Files restored!"
EOF

chmod +x ./touch/restore_files.sh

echo "✅ Minimal build setup complete!"
echo ""
echo "To build the app, run: ./touch/run_build.sh"
echo "To restore original files, run: ./touch/restore_files.sh"
echo ""
echo "The build uses minimal stubs and excludes problematic files to allow compilation."
echo "After building successfully, you can gradually restore and fix the problematic files one by one."
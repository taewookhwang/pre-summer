#!/bin/bash

# This script temporarily excludes problematic files from the build
# to allow the app to build successfully with minimal functionality.

echo "Setting up for minimal build..."

# Create temporary backups of problematic files
TEMP_DIR="./temp_backups"
mkdir -p $TEMP_DIR

# List of problematic files/directories to temporarily move
PROBLEM_FILES=(
  "Analytics/Events"
  "Analytics/AnalyticsManager.swift"
  "ViewModel/Admin"
  "ViewModel/Chat"
  "Network/WebSocket/AdminDashboardSocket.swift"
)

# Backup and rename files
for file in "${PROBLEM_FILES[@]}"; do
  if [ -e "$file" ]; then
    # Create directory structure in backup location
    dir=$(dirname "$file")
    mkdir -p "$TEMP_DIR/$dir"
    
    # Move the file or directory
    echo "Moving $file to $TEMP_DIR/$file.bak"
    mv "$file" "$TEMP_DIR/$file.bak"
  fi
done

# Create minimal placeholder files
mkdir -p Analytics/Events
mkdir -p ViewModel/Admin
mkdir -p ViewModel/Chat

# Create minimal AnalyticsManager
cat > Analytics/AnalyticsManager.swift << 'EOF'
import Foundation

class AnalyticsManager {
    private static let shared = AnalyticsManager()
    private init() {}
    
    static func configure(with logger: Any) {
        // Minimal implementation
    }
    
    static func trackEvent(_ event: Any) {
        // Minimal implementation
    }
}
EOF

# Create minimal Event protocols
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
    
    var stateDidChange: (() -> Void)?
    
    func loadDashboardData() {
        // Minimal implementation
    }
}
EOF

cat > ViewModel/Admin/MatchingViewModel.swift << 'EOF'
import Foundation

class MatchingViewModel {
    // Minimal implementation
}
EOF

cat > ViewModel/Admin/RealtimeMonitorViewModel.swift << 'EOF'
import Foundation

class RealtimeMonitorViewModel {
    // Minimal implementation
}
EOF

cat > ViewModel/Admin/UserManagementViewModel.swift << 'EOF'
import Foundation

class UserManagementViewModel {
    // Minimal implementation
}
EOF

# Create minimal Chat ViewModels
cat > ViewModel/Chat/ChatListViewModel.swift << 'EOF'
import Foundation

class ChatListViewModel {
    // Minimal implementation
}
EOF

cat > ViewModel/Chat/ChatRoomViewModel.swift << 'EOF'
import Foundation

class ChatRoomViewModel {
    // Minimal implementation
}
EOF

echo "Minimal build setup complete!"
echo "To restore original files, run: ./restore_files.sh"

# Create restore script
cat > ./touch/restore_files.sh << 'EOF'
#!/bin/bash

# This script restores the original files that were backed up
# by the minimal_build.sh script

echo "Restoring original files..."

TEMP_DIR="./temp_backups"

# Check if backup directory exists
if [ ! -d "$TEMP_DIR" ]; then
    echo "Error: Backup directory $TEMP_DIR not found!"
    exit 1
fi

# Find all backed up files
find "$TEMP_DIR" -name "*.bak" | while read backup_file; do
    # Get the original path
    original_path=${backup_file%.bak}
    original_path=${original_path#"$TEMP_DIR/"}
    
    # Remove the placeholder file/directory if it exists
    if [ -e "$original_path" ]; then
        rm -rf "$original_path"
    fi
    
    # Make sure parent directory exists
    parent_dir=$(dirname "$original_path")
    mkdir -p "$parent_dir"
    
    # Move the backup back to its original location
    echo "Restoring $original_path"
    mv "$backup_file" "$original_path"
done

# Clean up empty directories in the backup location
rm -rf "$TEMP_DIR"

echo "Original files restored!"
EOF

chmod +x ./touch/restore_files.sh

echo "Use xcodebuild command to build the project with these minimal files."
# Systems UI Wireframes & User Flows

Visual wireframes and user interaction flows for the Systems management interface, showing detailed layouts and navigation patterns.

## 🖼️ Main Systems Page Layout

### Desktop View (1440px+)
```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│ 🏢 RAS Dashboard                                    🔔 📧 ⚙️ 👤 John Doe              │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ 📊│ Systems Management                                                                   │
│ 🖥️│ ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│ 🔒│ │ 📊 System Overview                                          [+ Add System] [⚙️] │ │
│ 🛡️│ │ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐      │ │
│ 📋│ │ │ 📊 1,247│ │ 🟢 1,198│ │ 🔴   23 │ │ ⏳  156 │ │ ✅  89% │ │ 📈 +5.2%│      │ │
│ ⚙️│ │ │ Total   │ │ Active  │ │Critical │ │Pending  │ │Compliant│ │ Growth  │      │ │
│   │ │ │ Systems │ │ Systems │ │ Alerts  │ │ Updates │ │ Systems │ │ Rate    │      │ │
│   │ │ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘      │ │
│   │ │                                                                               │ │
│   │ │ 🔍 Advanced Search & Filters                                                  │ │
│   │ │ ┌─────────────────────────────────────────────────────────────────────────┐ │ │
│   │ │ │ 🔍 [Search systems by name, IP, description...]                        │ │ │
│   │ │ │ [🏷️ All Tags ▼] [📊 All Status ▼] [🔒 All Risk ▼] [📅 Date Range ▼] │ │ │
│   │ │ │ [💾 Saved Filters ▼] [🗑️ Clear All] [💾 Save Current Filter]         │ │ │
│   │ │ └─────────────────────────────────────────────────────────────────────────┘ │ │
│   │ │                                                                               │ │
│   │ │ 📋 Systems Data Grid                                                          │ │
│   │ │ ┌─────────────────────────────────────────────────────────────────────────┐ │ │
│   │ │ │ ☑️│System Name      │Type │Status │Risk│Last Scan │Owner    │Location│⚙️│ │ │
│   │ │ │ ──┼─────────────────┼─────┼───────┼────┼──────────┼─────────┼────────┼──│ │ │
│   │ │ │ ☑️│🖥️ WEB-PROD-01   │Web  │🟢 Up  │🟡 M│2h ago    │IT Team  │DC-A    │⋯ │ │ │
│   │ │ │ ☑️│🗄️ DB-PROD-02    │DB   │🟢 Up  │🔴 H│1h ago    │DB Team  │DC-A    │⋯ │ │ │
│   │ │ │ ☑️│📱 APP-STAGE-03  │App  │🟡Warn │🟡 M│30m ago   │Dev Team │DC-B    │⋯ │ │ │
│   │ │ │ ☑️│🌐 LB-PROD-04    │LB   │🟢 Up  │🟢 L│5m ago    │Net Team │DC-A    │⋯ │ │ │
│   │ │ │ ☑️│🔒 FW-PROD-05    │FW   │🟢 Up  │🟡 M│15m ago   │Sec Team │DMZ     │⋯ │ │ │
│   │ │ └─────────────────────────────────────────────────────────────────────────┘ │ │
│   │ │                                                                               │ │
│   │ │ 📄 Showing 1-50 of 1,247 systems                                             │ │
│   │ │ [← Previous] [1] [2] [3] ... [25] [Next →]                                   │ │
│   │ └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### Tablet View (768px - 1024px)
```
┌─────────────────────────────────────────────────────────────────────────┐
│ ☰ RAS Dashboard                                    🔔 ⚙️ 👤              │
├─────────────────────────────────────────────────────────────────────────┤
│ Systems Management                                    [+ Add] [⚙️]       │
│                                                                         │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐                        │
│ │📊 1,247 │ │🟢 1,198 │ │🔴   23  │ │⏳  156  │                        │
│ │Total    │ │Active   │ │Critical │ │Pending  │                        │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘                        │
│                                                                         │
│ 🔍 [Search systems...]                              [🔍] [🏷️] [📊]     │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ 🖥️ WEB-PROD-01                                    🟢 Up    🟡 Med   │ │
│ │ Web Server • Production • IT Team                                   │ │
│ │ 192.168.1.10 • Last scan: 2h ago                          [⋯]      │ │
│ ├─────────────────────────────────────────────────────────────────────┤ │
│ │ 🗄️ DB-PROD-02                                     🟢 Up    🔴 High  │ │
│ │ Database • Production • DB Team                                     │ │
│ │ 192.168.1.20 • Last scan: 1h ago                          [⋯]      │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ [Load More Systems...]                                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Mobile View (320px - 768px)
```
┌─────────────────────────────────────────┐
│ ☰ RAS Dashboard              🔔 👤      │
├─────────────────────────────────────────┤
│ Systems                       [+] [⚙️]  │
│                                         │
│ ┌─────────┐ ┌─────────┐                │
│ │📊 1,247 │ │🟢 1,198 │                │
│ │Total    │ │Active   │                │
│ └─────────┘ └─────────┘                │
│ ┌─────────┐ ┌─────────┐                │
│ │🔴   23  │ │⏳  156  │                │
│ │Critical │ │Pending  │                │
│ └─────────┘ └─────────┘                │
│                                         │
│ 🔍 [Search...]           [🔍]          │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🖥️ WEB-PROD-01        🟢 🟡        │ │
│ │ Web Server • Production             │ │
│ │ Last scan: 2h ago                   │ │
│ │ ← Swipe for actions                 │ │
│ ├─────────────────────────────────────┤ │
│ │ 🗄️ DB-PROD-02         🟢 🔴        │ │
│ │ Database • Production               │ │
│ │ Last scan: 1h ago                   │ │
│ │ ← Swipe for actions                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Load More...]                          │
└─────────────────────────────────────────┘
```

## 🔄 User Flow Diagrams

### 1. View System Details Flow
```
Systems List Page
        │
        ▼ (Click system row)
System Details Modal
        │
        ├─► Overview Tab (Default)
        │   ├─ Basic Information
        │   ├─ Status & Health
        │   ├─ Recent Activity
        │   └─ Quick Actions
        │
        ├─► Security Tab
        │   ├─ Risk Assessment
        │   ├─ Vulnerability Summary
        │   ├─ Security Controls
        │   └─ Compliance Status
        │
        ├─► Compliance Tab
        │   ├─ Framework Status
        │   ├─ Control Mappings
        │   ├─ Assessment Results
        │   └─ Remediation Plans
        │
        ├─► Vulnerabilities Tab
        │   ├─ Critical Vulnerabilities
        │   ├─ Vulnerability Timeline
        │   ├─ Patch Status
        │   └─ Risk Scores
        │
        ├─► Analytics Tab
        │   ├─ Performance Metrics
        │   ├─ Usage Statistics
        │   ├─ Trend Analysis
        │   └─ Capacity Planning
        │
        └─► Audit Log Tab
            ├─ Change History
            ├─ User Actions
            ├─ System Events
            └─ Compliance Events
```

### 2. Create System Flow
```
Systems List Page
        │
        ▼ (Click [+ Add System])
Create System Slide Panel
        │
        ├─► Step 1: Basic Information
        │   ├─ System Name *
        │   ├─ Description
        │   ├─ System Type *
        │   ├─ Environment *
        │   └─ Owner/Contact
        │   │
        │   ▼ (Click Next)
        │
        ├─► Step 2: Technical Details
        │   ├─ IP Address/Hostname
        │   ├─ Operating System
        │   ├─ Software/Services
        │   ├─ Network Location
        │   └─ Port Configuration
        │   │
        │   ▼ (Click Next)
        │
        ├─► Step 3: Security Classification
        │   ├─ Classification Level *
        │   ├─ Impact Level (FIPS 199) *
        │   ├─ ATO Status
        │   ├─ Compliance Requirements
        │   └─ Security Controls
        │   │
        │   ▼ (Click Next)
        │
        └─► Step 4: Review & Submit
            ├─ Summary of All Information
            ├─ Validation Results
            ├─ [Save Draft] [Create System]
            │
            ▼ (Click Create System)
            │
            Success Notification
            │
            ▼ (Auto-redirect)
            │
            System Details Modal (New System)
```

### 3. Bulk Operations Flow
```
Systems List Page
        │
        ▼ (Select multiple systems)
Bulk Action Bar Appears
        │
        ├─► Add Tags
        │   ├─ Tag Selection Modal
        │   ├─ Apply to Selected Systems
        │   └─ Success Notification
        │
        ├─► Update Status
        │   ├─ Status Selection Modal
        │   ├─ Confirmation Dialog
        │   ├─ Apply Changes
        │   └─ Progress Indicator
        │
        ├─► Run Scan
        │   ├─ Scan Type Selection
        │   ├─ Schedule Options
        │   ├─ Initiate Scans
        │   └─ Job Status Updates
        │
        ├─► Export Data
        │   ├─ Format Selection (CSV/Excel/PDF)
        │   ├─ Field Selection
        │   ├─ Generate Export
        │   └─ Download Link
        │
        └─► Delete Systems
            ├─ Confirmation Dialog
            ├─ Impact Assessment
            ├─ Cascade Options
            ├─ Execute Deletion
            └─ Audit Log Entry
```

## 📱 Responsive Breakpoints & Adaptations

### Navigation Adaptations
```
Desktop (1440px+):
┌─────────────────────────────────────────┐
│ [Logo] Navigation Items    User Menu    │
│ ├─ Dashboard                            │
│ ├─ Systems ◄ (expanded)                 │
│ │  ├─ System Inventory                  │
│ │  ├─ System Discovery                  │
│ │  └─ System Analytics                  │
│ ├─ Assets                               │
│ └─ Settings                             │
└─────────────────────────────────────────┘

Tablet (768px - 1024px):
┌─────────────────────────────────────────┐
│ [☰] [Logo]              [🔔] [👤]      │
│ Collapsible sidebar with icons + labels │
└─────────────────────────────────────────┘

Mobile (320px - 768px):
┌─────────────────────────────────────────┐
│ [☰] RAS Dashboard           [🔔] [👤]   │
│ Bottom navigation or drawer menu        │
└─────────────────────────────────────────┘
```

### Content Adaptations
```
Desktop: Data Grid (Table View)
├─ Full column visibility
├─ Sortable headers
├─ Inline actions
└─ Bulk selection

Tablet: Hybrid Card-Grid View
├─ Card-based layout
├─ Essential information visible
├─ Tap for details
└─ Swipe for actions

Mobile: List View
├─ Stacked information
├─ Priority information only
├─ Swipe gestures
└─ Bottom sheet modals
```

## 🎨 Visual States & Interactions

### Loading States
```
Initial Page Load:
┌─────────────────────────────────────────┐
│ Systems Management                      │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│ │ ░░░░░░░ │ │ ░░░░░░░ │ │ ░░░░░░░ │    │
│ │ ░░░░░░░ │ │ ░░░░░░░ │ │ ░░░░░░░ │    │
│ └─────────┘ └─────────┘ └─────────┘    │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘

Data Loading:
┌─────────────────────────────────────────┐
│ 🔄 Loading systems...                   │
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░ 40%               │
└─────────────────────────────────────────┘
```

### Error States
```
Connection Error:
┌─────────────────────────────────────────┐
│ ⚠️ Unable to load systems                │
│                                         │
│ Check your connection and try again.    │
│                                         │
│ [Retry] [Contact Support]               │
└─────────────────────────────────────────┘

No Data State:
┌─────────────────────────────────────────┐
│ 📊 No systems found                     │
│                                         │
│ Get started by adding your first system │
│                                         │
│ [+ Add System] [Import Systems]         │
└─────────────────────────────────────────┘
```

### Success States
```
Action Success:
┌─────────────────────────────────────────┐
│ ✅ System "WEB-PROD-01" created         │
│ [View System] [Create Another] [✕]      │
└─────────────────────────────────────────┘

Bulk Action Success:
┌─────────────────────────────────────────┐
│ ✅ 5 systems updated successfully       │
│ [View Changes] [Undo] [✕]               │
└─────────────────────────────────────────┘
```

This wireframe documentation provides a comprehensive visual guide for implementing the Systems UI with modern, responsive design patterns that work across all device types while maintaining enterprise security and usability standards.

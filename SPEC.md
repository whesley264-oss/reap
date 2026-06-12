# REAP - Specification Document

## 1. Project Overview

**Project Name:** REAP  
**Slogan:** Seu celular, sem mistérios.

**Core Functionality:** An Android diagnostic, monitoring, and real device optimization app. REAP provides transparent, useful information about device health without misleading "boost", "turbo", or "RAM cleaner" claims.

## 2. Technology Stack & Choices

### Framework & Language
- **Flutter 3.24.0** with Dart 3.5.0

### Key Libraries/Dependencies
- **State Management:** flutter_riverpod (^2.5.1)
- **Local Database:** sqflite (^2.3.3+1)
- **Charts:** fl_chart (^0.68.0)
- **Path Provider:** path_provider (^2.1.3)
- **Intl:** intl (^0.19.0)

### Native Integration
- **Kotlin** via MethodChannel for native Android APIs
- Battery information, device specs, storage analysis

### Architecture Pattern
- **Feature First** architecture
- Clean separation: features/ | core/

## 3. Feature List

### Phase 1 Features
1. **Dashboard** - Main screen with Reap Score, device summary, quick stats
2. **Reap Score** - Proprietary scoring system (0-100) with explanatory breakdown
3. **Battery Module** - Level, temperature, health estimation, status, voltage
4. **Storage Module** - Analysis by category (videos, images, downloads, etc.)
5. **Apps Module** - List installed apps with size, install date, last use
6. **Settings** - Theme selection (light/dark/system), monitoring preferences

### Phase 2 Features (Future)
7. **History** - Daily metrics storage with 7/30/90 day charts
8. **Insights** - Automatic observations and notifications
9. **Reports** - Auto-generated diagnostic reports with suggestions

### Key Constraints
- NO fake "boost" functionality
- NO RAM cleaner
- NO misleading performance claims
- Always explain data source for each metric
- Prioritize transparency over marketing

## 4. UI/UX Design Direction

### Visual Style
- Modern, clean design inspired by Material Design 3, Samsung One UI, Google Pixel
- Card-based layout with subtle shadows
- Simple icons, discrete animations
- NO gamer aesthetic, NO exaggerated "optimizer" visuals

### Color Scheme
- Primary: Deep Blue (#1565C0)
- Secondary: Teal (#00897B)
- Success: Green (#4CAF50)
- Warning: Amber (#FFC107)
- Error: Red (#F44336)
- Background: Light (#FAFAFA) / Dark (#121212)
- Surface: White (#FFFFFF) / Dark (#1E1E1E)

### Layout Approach
- Bottom navigation with 4 main tabs: Dashboard, Battery, Storage, Apps
- Settings accessible from app bar
- Cards for grouped information
- Clean typography with proper hierarchy

### Navigation Structure
```
├── Dashboard (Home)
│   ├── Reap Score Card
│   ├── Quick Stats (RAM, Storage, Battery, Temp)
│   └── Device Summary
├── Battery
│   ├── Current Status
│   ├── Temperature & Health
│   └── Historical Data (Phase 2)
├── Storage
│   ├── Categories Overview
│   ├── Large Files
│   └── Old Downloads
├── Apps
│   ├── Sorted List
│   ├── App Details
│   └── Usage Insights
└── Settings
    ├── Theme Selection
    ├── Monitoring Interval
    └── Notifications
```

## 5. Project Structure

```
lib/
├── main.dart
├── app.dart
├── features/
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers/
│   ├── battery/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers/
│   ├── storage/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers/
│   ├── apps/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── providers/
│   ├── settings/
│   │   ├── presentation/
│   │   │   └── screens/
│   │   └── providers/
│   ├── reports/ (Phase 2)
│   └── insights/ (Phase 2)
├── core/
│   ├── models/
│   ├── services/
│   │   ├── device_service.dart
│   │   ├── battery_service.dart
│   │   ├── storage_service.dart
│   │   └── database_service.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── constants/
│   └── utils/
└── shared/
    └── widgets/
```

## 6. Reap Score Algorithm

### Scoring Criteria (Total: 100 points)
- **Storage Free:** 30 points (30%+ free = full points, linear decrease)
- **Battery Health:** 30 points (based on estimated health %)
- **Temperature:** 20 points (normal range = full points)
- **Memory Usage:** 20 points (normal usage = full points)

### Score Ranges
- **95-100:** Excelente
- **80-94:** Bom
- **60-79:** Atenção
- **0-59:** Crítico

## 7. Data Models

### DeviceInfo
- model, manufacturer, androidVersion, apiLevel
- totalRam, freeRam, totalStorage, freeStorage
- uptime, cpuArchitecture, cpuCores

### BatteryInfo
- level, temperature, status, voltage, technology
- estimatedHealth, healthConfidence

### StorageAnalysis
- category, size, count, percentage
- largeFiles, oldDownloads

### AppInfo
- name, icon, size, installDate, lastUse
- usageCount, category

## 8. Native Channel Integration

### MethodChannel: 'com.reap/native'
- getDeviceInfo() → DeviceInfo
- getBatteryInfo() → BatteryInfo
- getStorageInfo() → StorageInfo
- getInstalledApps() → List<AppInfo>
- getAppUsageStats() → List<UsageInfo>
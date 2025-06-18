# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS menu bar application built with SwiftUI that monitors Datadog API endpoints and displays monitor status in the system status bar. The app shows OK/NOK counts with color-coded indicators and provides a popover interface for viewing detailed monitor information and configuring settings.

## Building and Running

- **Build**: Use Xcode to build the project by opening `datadog-monitor.xcodeproj`
- **Run**: Run directly from Xcode or build and run the resulting macOS app
- **Target**: macOS menu bar application (no traditional window, lives in status bar)

## Architecture

### Core Components

**App Entry Point**: `datadog_monitorApp.swift` - Contains the main SwiftUI App struct with an AppDelegate that manages the status bar item, popovers, and menu

**Background Job**: `monitorJob.swift` - Handles periodic API polling using DispatchQueue, manages status data, and updates the status bar icon. Uses recursive scheduling pattern for continuous monitoring.

**Data Flow**: 
- AppSettings → monitorJob → Webservice → Datadog API
- Results flow back through MonitorViewModel → StatusData → IconView (status bar)

**State Management**: Uses SwiftUI's `@Published` properties in ObservableObject classes, with `@Observable` StatusData for real-time status bar updates

### Key Classes

- **AppDelegate**: Manages NSStatusItem, NSPopover instances, and menu actions
- **monitorJob**: Background polling service with start/stop lifecycle
- **MonitorListViewModel**: Manages monitor data for the main content view
- **AppSettings**: Handles UserDefaults persistence with suite identifier "datadog-monitor.kloosterman.eu"
- **Webservice**: Makes authenticated HTTP requests to Datadog API with DD-API-KEY and DD-APPLICATION-KEY headers

### UI Structure

- **Status Bar**: IconView showing OK/NOK counts with conditional coloring
- **Main Popover**: ContentView with monitor list (400x300)
- **Settings Popover**: SettingsView with configuration form (600x300)
- **Menu**: Shows monitors, settings, and quit options

## Configuration

Settings are stored in UserDefaults with suite name "datadog-monitor.kloosterman.eu":
- API URL (default: https://api.datado/api/v1/monitor/search)
- API Key and Application Key for Datadog authentication  
- Polling interval in seconds (default: 60)
- Query parameter for filtering monitors

## Development Notes

- Uses async/await for API calls
- NSHostingController bridges SwiftUI views into NSPopover
- Status bar icon is a custom SwiftUI view embedded in NSStatusItem
- Monitor status mapping: "OK" → green, "Warn" → yellow, "Alert" → red
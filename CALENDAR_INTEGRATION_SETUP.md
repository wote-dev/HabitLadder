# Calendar Integration Setup Guide

## Overview

The HabitLadder app now includes iOS Calendar integration as a premium feature. When enabled, the app will automatically create calendar events for completed habits in a dedicated "HabitLadder" calendar.

## Setup Requirements

### 1. Info.plist Configuration

To use calendar integration, you must add the calendar usage description to your app's Info.plist file. This is required by Apple for EventKit access.

Add the following key-value pair to your Info.plist:

```xml
<key>NSCalendarsUsageDescription</key>
<string>HabitLadder would like to access your calendar to create events for completed habits. This helps you track your progress in your calendar app.</string>
```

#### For Xcode 13+:

1. Open your project in Xcode
2. Select your app target
3. Go to the "Info" tab
4. Click the "+" button to add a new row
5. Select "Privacy - Calendars Usage Description" from the dropdown
6. Enter the usage description: "HabitLadder would like to access your calendar to create events for completed habits. This helps you track your progress in your calendar app."

### 2. File Integration

Ensure the following files are added to your Xcode project:

- `CalendarManager.swift` - Core calendar integration logic
- Updated `SettingsView.swift` - UI for calendar integration settings
- Updated `HabitManager.swift` - Integration with habit completion logic

## Features

### For Premium Users Only

Calendar integration is restricted to premium users only. Free users will see a premium upgrade prompt when trying to access calendar features.

### Automatic Event Creation

When a habit is marked as complete:

- An all-day calendar event is automatically created
- Event title: "Completed: [Habit Name]"
- Event is added to a dedicated "HabitLadder" calendar
- Duplicate events for the same habit on the same day are prevented

### Settings Management

Premium users can:

- Toggle calendar integration on/off
- Grant/revoke calendar permissions
- Sync existing habit completions to calendar
- View permission status and error messages

### Calendar Management

The app will:

- Create a "HabitLadder" calendar if it doesn't exist
- Use appropriate calendar source (local or default)
- Handle permission states gracefully
- Provide clear error messages for permission issues

## Usage Instructions

### Enabling Calendar Integration

1. Upgrade to Premium (if not already)
2. Go to Settings
3. Find "Calendar Integration" section
4. Toggle "Calendar Sync" on
5. Grant calendar permission when prompted
6. Optionally tap "Sync Past Completions" to add existing habit completions

### Managing Permissions

If calendar permission is denied:

1. The app will show a warning message
2. Tap the warning to open iOS Settings
3. Navigate to HabitLadder > Calendars
4. Enable calendar access
5. Return to the app

### Viewing Calendar Events

1. Open the iOS Calendar app
2. Look for the "HabitLadder" calendar in your calendar list
3. Toggle it on to view habit completion events
4. Events appear as all-day events on completion dates

## Technical Details

### CalendarManager Class

Key methods:

- `toggleCalendarIntegration()` - Enable/disable integration
- `createHabitCompletionEvent()` - Create single event
- `syncAllHabitsToCalendar()` - Bulk sync existing completions
- `removeAllHabitLadderEvents()` - Cleanup all events

### Permission Handling

- Uses EventKit framework for calendar access
- Handles all permission states: not determined, denied, authorized
- Graceful fallback when permissions are not granted
- Clear user messaging for permission issues

### Data Privacy

- Only creates events for completed habits
- No personal data beyond habit names is stored in calendar
- Events are clearly marked as coming from HabitLadder
- Users maintain full control over calendar access

## Troubleshooting

### Common Issues

1. **Calendar permission denied**

   - Solution: Go to iOS Settings > HabitLadder > Calendars and enable access

2. **Events not appearing**

   - Check if "HabitLadder" calendar is enabled in Calendar app
   - Verify calendar integration is enabled in Settings
   - Ensure you have premium access

3. **Duplicate events**

   - The app prevents duplicates automatically
   - If duplicates exist, they may be from manual sync operations

4. **Missing HabitLadder calendar**
   - The app creates this automatically when first needed
   - Check calendar app for the calendar in your calendar list

### Debug Information

In debug builds, you can check:

- Calendar permission status
- Event creation success/failure
- Calendar creation status

## Future Enhancements

Potential future features:

- Custom calendar selection
- Event reminder customization
- Calendar event categorization
- Export/import functionality

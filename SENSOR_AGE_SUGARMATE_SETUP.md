# Sensor Age Display in Sugarmate - Setup Guide

## Overview
This guide explains how to display your daughter's Dexcom sensor expiry date and time in Sugarmate using Nightscout's SAGE (Sensor Age) plugin.

## What Changed
The Pebble API endpoint (used by Sugarmate) has been enhanced to include sensor age information. The following fields are now available in the API response:
- `sensorAge` - Display format (e.g., "7d4h")
- `sensorDays` - Number of days since sensor start
- `sensorHours` - Additional hours beyond full days
- `sensorRemaining` - Calculated time remaining until sensor expiry

## Configuration Steps

### 1. Enable the SAGE Plugin
You need to enable the SAGE plugin in your Nightscout configuration. This is done through environment variables.

**For Azure Web App:**
1. Go to your Azure Portal
2. Navigate to your App Service (carmensugar)
3. Go to **Configuration** → **Application settings**
4. Find or add the `ENABLE` setting
5. Make sure it includes `sage` in the list, for example:
   ```
   cage sage iage iob cob basal
   ```
6. Click **Save** and restart your app

**Important:** Make sure `sage` is in your ENABLE list!

### 2. Configure SAGE Alerts (Optional)
You can optionally set up alerts for sensor changes:

Add these environment variables in Azure:
- `SAGE_ENABLE_ALERTS` = `true` (enable notifications)
- `SAGE_INFO` = `144` (info alert at 6 days - 144 hours)
- `SAGE_WARN` = `164` (warning at 6 days 20 hours - 164 hours)
- `SAGE_URGENT` = `166` (urgent at 6 days 22 hours - 166 hours)

### 3. Log Sensor Changes
For the sensor age to be tracked, you need to log sensor change events in Nightscout:

**Method 1: Through Nightscout Web Interface**
1. Go to https://carmensugar.azurewebsites.net/
2. Click the **+** button (Add Treatment)
3. Select **"Sensor Start"** or **"Sensor Change"** from Event Type
4. Enter the date/time when you inserted the new sensor
5. Optionally add notes (like sensor code, transmitter ID)
6. Click **Submit**

**Method 2: Through Nightscout Care Portal (recommended for regular changes)**
- Event Type: **Dexcom Sensor Start** or **Dexcom Sensor Change**
- Always enter the actual time when the sensor was inserted

### 4. Adjust Sensor Expiry Calculation
The code is currently set for **Dexcom G6** sensors (10 days = 240 hours).

If you're using **Dexcom G7** (10.5 days = 252 hours), you need to modify this:

Edit [lib/server/pebble.js](lib/server/pebble.js#L126) and change:
```javascript
var expiryHours = 240; // Change to 252 for G7
```

### 5. Verify the API
Once configured and after logging a sensor start event, you can verify the data:

Open in your browser:
```
https://carmensugar.azurewebsites.net/pebble
```

You should see sensor age fields in the JSON response:
```json
{
  "bgs": [{
    "sgv": "120",
    "sensorAge": "5d8h",
    "sensorDays": 5,
    "sensorHours": 8,
    "sensorRemaining": "4d16h",
    ...
  }]
}
```

### 6. Sugarmate Display
After making these changes:
1. Sugarmate should automatically pick up the new sensor age fields from the Pebble API
2. The sensor age/expiry information will appear in your Sugarmate display
3. You may need to wait a few minutes for Sugarmate to refresh its data

**Note:** Sugarmate's display of this information depends on how they've implemented their interface. The data is now available in their API feed, but the exact display format is controlled by Sugarmate's app.

## Troubleshooting

### Sensor age not showing?
1. Verify `sage` is in your ENABLE list
2. Make sure you've logged at least one "Sensor Start" or "Sensor Change" event
3. Check the Pebble API response to confirm data is present
4. Restart your Azure App Service after configuration changes

### Wrong sensor age?
- Make sure the sensor start/change event has the correct date and time
- Delete incorrect sensor events and add a new one with the correct time

### Sugarmate not displaying it?
- The data is now available in the API feed
- Sugarmate needs to update their app to display these fields
- Contact Sugarmate support to request this feature if they don't already show it

## Support
For Nightscout issues: https://discord.gg/rTKhrqz
For Sugarmate issues: Contact Sugarmate support

## Technical Details
The Pebble API endpoint (`/pebble`) now includes sensor age data when:
1. The `sage` plugin is enabled
2. At least one sensor start/change event exists in treatments
3. The sensor event is not older than the calculated expiry time

The calculation uses the SAGE plugin's treatment data to determine:
- Current sensor age
- Time remaining until expiry (based on sensor type)
- Formatted display strings

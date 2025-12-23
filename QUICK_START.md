# Quick Setup - Sensor Age in Sugarmate

## 1. Deploy Code Changes
```powershell
# From the cgm-remote-monitor directory
.\deploy-to-azure.ps1
```

## 2. Configure Azure Environment Variables

Go to Azure Portal → Your App Service → Configuration → Application settings

### Required Setting:
- **ENABLE**: Add `sage` to the list
  - Example: `cage sage iage iob cob basal`

### Optional Settings (for alerts):
- **SAGE_ENABLE_ALERTS**: `true`
- **SAGE_INFO**: `144` (6 days)
- **SAGE_WARN**: `164` (6 days 20 hours)  
- **SAGE_URGENT**: `166` (6 days 22 hours)

Click **Save** and **Restart** the app

## 3. Log Sensor Start Event

Go to: https://carmensugar.azurewebsites.net/

1. Click **+** button
2. Event Type: **"Dexcom Sensor Start"**
3. Enter date/time of current sensor insertion
4. Click **Submit**

## 4. Verify

Check: https://carmensugar.azurewebsites.net/pebble

Look for these fields in the JSON:
```json
{
  "bgs": [{
    "sensorAge": "5d8h",
    "sensorDays": 5,
    "sensorHours": 8,
    "sensorRemaining": "4d16h"
  }]
}
```

## 5. Sugarmate

Sugarmate will automatically receive this data from your Nightscout feed. The display depends on Sugarmate's implementation.

---

## Sensor Type Configuration

**For Dexcom G7** (10.5 days instead of 10):

Edit: `lib/server/pebble.js` line ~126
```javascript
var expiryHours = 252; // Changed from 240
```

Then redeploy.

---

## Need Help?

See [SENSOR_AGE_SUGARMATE_SETUP.md](SENSOR_AGE_SUGARMATE_SETUP.md) for detailed instructions.

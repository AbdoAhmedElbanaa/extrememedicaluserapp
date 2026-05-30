import 'package:firebase_database/firebase_database.dart';
import '../models/faq_model.dart';
import '../models/error_code_model.dart';
import '../models/diagnose_option_model.dart';

class KnowledgeCenterService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<List<FaqModel>> getFaqs() async {
    final ref = _db.ref('knowledge_center/faqs');
    final snapshot = await ref.get();
    
    if (!snapshot.exists || snapshot.value == null) {
      // Bootstrap default values
      final defaults = _getDefaultFaqs();
      for (var faq in defaults) {
        await ref.child(faq.id).set(faq.toMap());
      }
      return defaults;
    }

    final List<FaqModel> list = [];
    final val = snapshot.value;
    if (val is Map) {
      val.forEach((key, value) {
        if (value != null) {
          list.add(FaqModel.fromMap(key.toString(), Map<dynamic, dynamic>.from(value as Map)));
        }
      });
    } else if (val is List) {
      for (int i = 0; i < val.length; i++) {
        final value = val[i];
        if (value != null) {
          list.add(FaqModel.fromMap(i.toString(), Map<dynamic, dynamic>.from(value as Map)));
        }
      }
    }
    return list;
  }

  Future<List<ErrorCodeModel>> getErrorCodes() async {
    final ref = _db.ref('knowledge_center/errors');
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      // Bootstrap default values
      final defaults = _getDefaultErrors();
      for (var err in defaults) {
        await ref.child(err.id).set(err.toMap());
      }
      return defaults;
    }

    final List<ErrorCodeModel> list = [];
    final val = snapshot.value;
    if (val is Map) {
      val.forEach((key, value) {
        if (value != null) {
          list.add(ErrorCodeModel.fromMap(key.toString(), Map<dynamic, dynamic>.from(value as Map)));
        }
      });
    } else if (val is List) {
      for (int i = 0; i < val.length; i++) {
        final value = val[i];
        if (value != null) {
          list.add(ErrorCodeModel.fromMap(i.toString(), Map<dynamic, dynamic>.from(value as Map)));
        }
      }
    }
    // Sort by code
    list.sort((a, b) => a.code.compareTo(b.code));
    return list;
  }

  Future<List<DiagnoseOptionModel>> getDiagnoseOptions() async {
    final ref = _db.ref('knowledge_center/diagnose');
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      // Bootstrap default values
      final defaults = _getDefaultDiagnoseOptions();
      for (var opt in defaults) {
        await ref.child(opt.id).set(opt.toMap());
      }
      return defaults;
    }

    final List<DiagnoseOptionModel> list = [];
    final val = snapshot.value;
    if (val is Map) {
      val.forEach((key, value) {
        if (value != null) {
          list.add(DiagnoseOptionModel.fromMap(key.toString(), Map<dynamic, dynamic>.from(value as Map)));
        }
      });
    } else if (val is List) {
      for (int i = 0; i < val.length; i++) {
        final value = val[i];
        if (value != null) {
          list.add(DiagnoseOptionModel.fromMap(i.toString(), Map<dynamic, dynamic>.from(value as Map)));
        }
      }
    }
    return list;
  }

  List<FaqModel> _getDefaultFaqs() {
    return [
      FaqModel(id: '1', question: 'How do I add a new device?', answer: 'Go to the Devices tab, tap the "+" floating action button or "Add New Device" button, and follow the on-screen instructions.'),
      FaqModel(id: '2', question: 'How do I update the firmware?', answer: 'Ensure your device is connected to Wi-Fi. Go to the device settings page and click "Update Firmware".'),
      FaqModel(id: '3', question: 'Why is my device showing offline?', answer: 'Check if your internet connection is active. Ensure the device is powered on and within range of your router.'),
      FaqModel(id: '4', question: 'How do I reset my device to factory settings?', answer: 'Hold the power button for 10 seconds. Release when the LED starts flashing yellow. Follow setup instructions again.'),
      FaqModel(id: '5', question: 'Can I manage multiple devices from one account?', answer: 'Yes, you can register and control multiple devices under the same clinic/user account.'),
      FaqModel(id: '6', question: 'How do I change the temperature unit?', answer: 'Go to Settings -> Preferences and toggle between Celsius (°C) and Fahrenheit (°F).'),
      FaqModel(id: '7', question: 'What does the warranty cover?', answer: 'The warranty covers manufacturing defects, hardware failure, and battery issues for up to 2 years.'),
    ];
  }

  List<ErrorCodeModel> _getDefaultErrors() {
    return [
      ErrorCodeModel(
        id: 'E101',
        code: 'E101',
        title: 'Temperature Sensor Fault',
        description: 'Sensor reading out of expected range or disconnected.',
        severity: 'medium',
        causes: ['Damaged sensor probe', 'Loose connector pin', 'Extreme environmental temperature'],
        steps: ['Inspect the physical sensor probe for damage.', 'Clean the connector contact points with dry cloth.', 'Power cycle the device and re-test.'],
        tutorialTitle: 'Clean & Fix Temperature Sensor',
        tutorialDuration: '2:15 min',
      ),
      ErrorCodeModel(
        id: 'E102',
        code: 'E102',
        title: 'Control Module Error',
        description: 'Main control board encountered an unhandled exception.',
        severity: 'critical',
        causes: ['Loose or damaged ribbon cable', 'Firmware corruption after incomplete update', 'Physical impact or vibration damage', 'Manufacturing defect (rare, covered under warranty)'],
        steps: [
          'Power off the device completely by holding the button for 8 seconds.',
          'Wait 30 seconds, then open the rear access panel using the provided T8 Torx screwdriver.',
          'Locate the ribbon cable connecting the control module (orange, 12-pin connector). Check for bends, damage or loose fit.',
          'Gently reseat the connector — press firmly until you hear a click.',
          'Replace the access panel and power on the device. Monitor for 5 minutes.',
          'If E102 persists, the control module may require replacement. Contact support with your SN.'
        ],
        tutorialTitle: 'Watch Fix Tutorial',
        tutorialDuration: '4:32 min',
      ),
      ErrorCodeModel(
        id: 'E103',
        code: 'E103',
        title: 'Communication Timeout',
        description: 'Device failed to sync with the server within the expected time.',
        severity: 'low',
        causes: ['Intermittent Wi-Fi signal', 'Router DHCP IP assignment failure', 'Server maintenance'],
        steps: ['Ensure the device is within 10 meters of the Wi-Fi router.', 'Restart the Wi-Fi router and the medical device.', 'Check for server status updates in the Help section.'],
        tutorialTitle: 'Troubleshoot Connectivity',
        tutorialDuration: '3:10 min',
      ),
      ErrorCodeModel(
        id: 'E301',
        code: 'E301',
        title: 'Battery Critical Level',
        description: 'Battery is below 10% — device may lose data if not charged.',
        severity: 'medium',
        causes: ['Long usage without charging', 'Faulty charging adapter', 'Aging lithium cell'],
        steps: ['Connect the device to the original power supply immediately.', 'Verify that the charging indicator LED turns red/orange.', 'Leave the device to charge for at least 2 hours before disconnecting.'],
        tutorialTitle: 'Battery Care & Charging',
        tutorialDuration: '1:45 min',
      ),
      ErrorCodeModel(
        id: 'E302',
        code: 'E302',
        title: 'Power Supply Issue',
        description: 'Voltage supply is unstable or outside acceptable range.',
        severity: 'critical',
        causes: ['Using non-standard power adapter', 'Fluctuations in mains voltage', 'Internal power management circuit failure'],
        steps: ['Unplug the current power adapter immediately.', 'Verify you are using the official 5V 2A charger provided.', 'Plug the adapter into a different wall socket directly without extensions.'],
        tutorialTitle: 'Power Issues Guide',
        tutorialDuration: '2:50 min',
      ),
    ];
  }

  List<DiagnoseOptionModel> _getDefaultDiagnoseOptions() {
    return [
      DiagnoseOptionModel(
        id: '1',
        title: 'Device Not Responding',
        iconName: 'bolt',
        colorHex: '#ef4444',
        description: 'Steps to recover a frozen or unresponsive device',
        steps: ['Perform a hard reset by holding the power button for 10 seconds.', 'Ensure the charging adapter is connected and power is flowing.', 'Let the device sit for 15 minutes, then try powering on again.'],
      ),
      DiagnoseOptionModel(
        id: '2',
        title: 'Connectivity Problem',
        iconName: 'wifi',
        colorHex: '#3b82f6',
        description: 'Resolve Wi-Fi disconnection and sync issues',
        steps: ['Verify your Wi-Fi is 2.4GHz (5GHz is not supported).', 'Check that the router password was entered correctly.', 'Reduce the distance between the device and the router.'],
      ),
      DiagnoseOptionModel(
        id: '3',
        title: 'Temperature Issues',
        iconName: 'thermostat',
        colorHex: '#f59e0b',
        description: 'Handle incorrect temperature readings or sensor errors',
        steps: ['Ensure the sensor is clean and free of dust or moisture.', 'Compare reading with a secondary standard thermometer.', 'Recalibrate the offset settings in the device configuration.'],
      ),
      DiagnoseOptionModel(
        id: '4',
        title: 'Power / Battery',
        iconName: 'battery_alert_rounded',
        colorHex: '#10b981',
        description: 'Resolve fast battery drain or charging failures',
        steps: ['Do not leave the screen back-light on continuously.', 'Check the USB charging port for lint or dirt particles.', 'Charge to 100% and measure run time.'],
      ),
      DiagnoseOptionModel(
        id: '5',
        title: 'Sync Failures',
        iconName: 'sync',
        colorHex: '#8b5cf6',
        description: 'Ensure data is saved and synced to the cloud',
        steps: ['Check if your user account is signed in on the app.', 'Tap the manual sync button on the Home screen.', 'Clear app cache and try restarting the app.'],
      ),
      DiagnoseOptionModel(
        id: '6',
        title: 'Error Code Showing',
        iconName: 'warning',
        colorHex: '#ec4899',
        description: 'Search for specific error code screens',
        steps: ['Note down the error code (e.g. E101).', 'Go to the Error Codes tab and look up the instructions.', 'If the code is not listed, contact Support with details.'],
      ),
    ];
  }
}

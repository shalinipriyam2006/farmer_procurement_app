/**
 * Hardware Abstraction Layer & Device Adapters
 * Provides a standardized interface for physical and simulated procurement hardware devices.
 */

class WeighingDeviceAdapter {
  constructor(deviceId, centreId, connectionType = 'SIMULATOR') {
    this.deviceId = deviceId;
    this.centreId = centreId;
    this.connectionType = connectionType;
  }

  async readWeight() {
    throw new Error('readWeight() must be implemented by concrete WeighingDeviceAdapter subclass.');
  }
}

class SimulatorWeighingAdapter extends WeighingDeviceAdapter {
  constructor(deviceId = 'SCALE-SIM-01', centreId = 'CENTRE-01') {
    super(deviceId, centreId, 'SIMULATOR');
  }

  async readWeight(customWeightKg = 50.25, customBags = 45) {
    const weightKg = parseFloat(customWeightKg);
    const weightQuintals = parseFloat((weightKg * customBags / 100).toFixed(2));
    return {
      deviceId: this.deviceId,
      centreId: this.centreId,
      connectionType: this.connectionType,
      readingStatus: 'STABLE_FINAL',
      weightKgPerBag: weightKg,
      bagCount: customBags,
      weightKg: weightKg * customBags,
      weightQuintals: weightQuintals,
      timestamp: new Date().toISOString()
    };
  }
}

class BluetoothWeighingAdapter extends WeighingDeviceAdapter {
  constructor(deviceId, centreId, macAddress) {
    super(deviceId, centreId, 'BLUETOOTH_GATT');
    this.macAddress = macAddress;
  }

  async readWeight() {
    // Hardware integration point for Bluetooth GATT scale service
    return {
      deviceId: this.deviceId,
      centreId: this.centreId,
      connectionType: this.connectionType,
      readingStatus: 'BLUETOOTH_PENDING_HARDWARE',
      note: 'Hardware-ready: Connect real Bluetooth scale device to parse BLE GATT payload.'
    };
  }
}

class WiFiWeighingAdapter extends WeighingDeviceAdapter {
  constructor(deviceId, centreId, ipAddress, port) {
    super(deviceId, centreId, 'WIFI_TCP');
    this.ipAddress = ipAddress;
    this.port = port;
  }

  async readWeight() {
    // Hardware integration point for WiFi TCP/UDP socket scale
    return {
      deviceId: this.deviceId,
      centreId: this.centreId,
      connectionType: this.connectionType,
      readingStatus: 'WIFI_PENDING_HARDWARE',
      note: 'Hardware-ready: Connect real WiFi TCP scale socket.'
    };
  }
}

class RS232WeighingAdapter extends WeighingDeviceAdapter {
  constructor(deviceId, centreId, comPort, baudRate = 9600) {
    super(deviceId, centreId, 'RS232_SERIAL');
    this.comPort = comPort;
    this.baudRate = baudRate;
  }

  async readWeight() {
    // Hardware integration point for RS-232 Serial COM Port scale
    return {
      deviceId: this.deviceId,
      centreId: this.centreId,
      connectionType: this.connectionType,
      readingStatus: 'RS232_PENDING_HARDWARE',
      note: 'Hardware-ready: Connect real RS-232 COM port.'
    };
  }
}

class QualityDeviceAdapter {
  constructor(deviceId, centreId, connectionType = 'SIMULATOR') {
    this.deviceId = deviceId;
    this.centreId = centreId;
    this.connectionType = connectionType;
  }

  async analyzeQuality() {
    throw new Error('analyzeQuality() must be implemented by concrete QualityDeviceAdapter subclass.');
  }
}

class SimulatorQualityAdapter extends QualityDeviceAdapter {
  constructor(deviceId = 'QUAL-SIM-01', centreId = 'CENTRE-01') {
    super(deviceId, centreId, 'SIMULATOR');
  }

  async analyzeQuality(customMoisture = 14.2, customForeignMatter = 0.5) {
    const moisture = parseFloat(customMoisture);
    const foreignMatter = parseFloat(customForeignMatter);
    const isAccepted = moisture <= 17.0 && foreignMatter <= 2.0;

    let grade = 'Grade A (FAQ Standard)';
    if (moisture > 15.0 && moisture <= 17.0) {
      grade = 'Paddy Common';
    }

    return {
      deviceId: this.deviceId,
      centreId: this.centreId,
      connectionType: this.connectionType,
      moisturePercentage: moisture,
      foreignMatterPercentage: foreignMatter,
      qualityGrade: grade,
      qualityStatus: isAccepted ? 'ACCEPTED' : 'REJECTED',
      rejectionReason: isAccepted ? null : `Moisture (${moisture}%) exceeds government FAQ maximum limit of 17.0%.`,
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = {
  WeighingDeviceAdapter,
  SimulatorWeighingAdapter,
  BluetoothWeighingAdapter,
  WiFiWeighingAdapter,
  RS232WeighingAdapter,
  QualityDeviceAdapter,
  SimulatorQualityAdapter
};

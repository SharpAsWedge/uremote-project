// import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const URemoteApp());
}

class URemoteApp extends StatelessWidget {

  const URemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'U-Remote App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double buttonSize = MediaQuery.of(context).size.width / 2 - 24;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222), // Set AppBar color
        title: const Center(
          child: Text(
            'U-Remote App',
            style: TextStyle(color: Colors.white), // Set AppBar text color
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF222222), // Replace with your desired hex color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () { // Navigate to the My Devices screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyDevicesScreen(myDevices: MyDevicesManager().myDevices),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color(0xFF454545), // Background color of the button
                    foregroundColor: Colors.white, // Text color
                    minimumSize: const Size(double.infinity, 50), // Button spans full width
                  ),
                  child: const Text(
                    'My Devices',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    _buildSquareButton(context, buttonSize, 'TV', Icons.tv, Colors.white),
                    _buildSquareButton(context, buttonSize, 'Air Conditioner', Icons.ac_unit, Colors.white),
                    _buildSquareButton(context, buttonSize, 'Projector', Icons.videocam, Colors.white),
                    _buildSquareButton(context, buttonSize, 'Coming Soon...', Icons.more_horiz, Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 10.0), // Add spacing between the Wrap and the new button
              _buildSquareButton(context, buttonSize - 24, 'Add your own device', Icons.add, Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(BuildContext context, double size, String label, IconData icon, Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: () {
          if (label != 'Coming Soon...' && label != 'Add your own device') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BrandScreen(deviceName: label)),
            );
          } else if (label == 'Add your own device') {
            // Handle add your own device action
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: const Color(0xFF454545), // Background color of the button
          foregroundColor: color, // Text and icon color
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: color),
            const SizedBox(height: 8.0),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class BrandScreen extends StatefulWidget {
  final String deviceName;

  const BrandScreen({super.key, required this.deviceName});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<String> brands = [];

  @override
  void initState() {
    super.initState();
    _loadBrands(widget.deviceName);
  }

  Future<void> _loadBrands(String deviceName) async {
    final brandsList = await _loadBrandList(deviceName);
    setState(() {
      brands = brandsList;
    });
  }

  Future<List<String>> _loadBrandList(String deviceName) async {
    String fileName = 'assets/brands_${deviceName.toLowerCase()}.txt';
    String brandsText = await rootBundle.loadString(fileName);
    List<String> brandLines = brandsText.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return brandLines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //  back button
        backgroundColor: const Color(0xFF222222), // Set AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color
        title: const Text(
          'Select Brand', // Display deviceName and brand in title
          style: TextStyle(color: Colors.white), // Set AppBar text color
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF222222), // Custom background color
        child: Center(
          child: brands.isEmpty
              ? const CircularProgressIndicator() // Show loading indicator while brands are loading
              : ListView.builder(
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    String brand = brands[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToDeviceControl(context, brand); // Navigate to device control with selected brand
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF454545), // Button background color
                          foregroundColor: Colors.white, // Button text color
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        child: Text(
                          brand, // Display brand name on button
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _navigateToDeviceControl(BuildContext context, String selectedBrand) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DeviceControl(deviceName: widget.deviceName, brand: selectedBrand)),
    );
  }
}

class MyDevicesScreen extends StatelessWidget {
  final List<String> myDevices;

  const MyDevicesScreen({required this.myDevices, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Devices'),
        backgroundColor: const Color(0xFF222222),
      ),
      body: ListView.builder(
        itemCount: myDevices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              myDevices[index],
              style: const TextStyle(color: Colors.white),
            ),
             onTap: () {
              // Parse the device type and brand from the myDevices item
              List<String> parts = myDevices[index].split(' - ');
              String deviceType = parts[0];
              String brand = parts[1];

              // Navigate to the relevant device control screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceControl(
                    deviceName: deviceType,
                    brand: brand,
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: const Color(0xFF222222),
    );
  }
}

class MyDevicesManager {
  static final MyDevicesManager _instance = MyDevicesManager._internal();

  factory MyDevicesManager() {
    return _instance;
  }

  MyDevicesManager._internal();

  List<String> myDevices = [];

  bool isFavorite(String device) {
    return myDevices.contains(device);
  }

  void toggleFavorite(String device) {
    if (isFavorite(device)) {
      myDevices.remove(device);
    } else {
      myDevices.add(device);
    }
  }
}

class DeviceControl extends StatelessWidget {
  final String deviceName;
  final String brand;

  const DeviceControl({required this.deviceName, required this.brand, super.key});

  @override
  Widget build(BuildContext context) {

    switch (deviceName) {
      case 'TV':
        return TVControlScreen(brand: brand);
      case 'Air Conditioner':
        return AirConditionerControlScreen(brand: brand);
      case 'Projector':
        return ProjectorControlScreen(brand: brand);
        /*
      case 'Custom Devices':
        return CustomDeviceControlScreen(brand: brand);
      */
      default:
        return Container(); // Handle unknown device types or fallback
      }
    }
}

class TVControlScreen extends StatefulWidget {
  final String brand;

  const TVControlScreen({required this.brand, super.key});

  @override
  State<TVControlScreen> createState() => _TVControlScreenState();
}

class _TVControlScreenState extends State<TVControlScreen> {

    late String deviceBrandCombo;

    @override
    void initState() {
      super.initState();
      deviceBrandCombo = 'TV - ${widget.brand}';
    }

    @override
    Widget build(BuildContext context) {

      const double circularButtonSize = 64.0;
      const double capsuleButtonWidth = 80.0;
      const double capsuleButtonHeight = 160.0;
      final double placeholderButtonWidth = (MediaQuery.of(context).size.width - 60) / 3;
      const double placeholderButtonHeight = 50.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //  back button
        backgroundColor: const Color(0xFF222222), // Set AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color
        title: Text(
          'Control $deviceBrandCombo', // Display deviceName and brand in title
          style: const TextStyle(color: Colors.white), // Set AppBar text color
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              MyDevicesManager().isFavorite(deviceBrandCombo) ? Icons.favorite : Icons.favorite_border,
              color: MyDevicesManager().isFavorite(deviceBrandCombo) ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                MyDevicesManager().toggleFavorite(deviceBrandCombo);
            });
            }
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF222222),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(context, circularButtonSize, 'Power', Icons.power_settings_new, Colors.red),
                    _buildCircularButton(context, circularButtonSize, 'Mute', Icons.volume_off, Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCapsuleButton(context, capsuleButtonWidth, capsuleButtonHeight, 'Volume Up', Icons.volume_up, 'Volume Down', Icons.volume_down, Colors.white),
                  const SizedBox(width: 20.0),
                  _buildConcentricCircleButton(context, 140.0, Colors.white),
                  const SizedBox(width: 20.0),
                  _buildCapsuleButton(context, capsuleButtonWidth, capsuleButtonHeight, 'Channel Up', Icons.arrow_upward, 'Channel Down', Icons.arrow_downward, Colors.white),
                ],
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(context, circularButtonSize, 'Back', Icons.keyboard_backspace_rounded , Colors.white),
                    _buildCircularButton(context, circularButtonSize, 'Source', Icons.screen_share_rounded , Colors.white),
                    _buildCircularButton(context, circularButtonSize, 'Menu', Icons.menu , Colors.white),
                    _buildCircularButton(context, circularButtonSize, 'Home', Icons.home , Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: List.generate(3, (index) {
                  return _buildRoundedRectangularButton(context, placeholderButtonWidth, placeholderButtonHeight, 'Button ${index + 1}', Icons.add_circle_outlined, Colors.white);
                }),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _showKeypad(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: const Color(0xFF454545),
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dialpad, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text('Keypad', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AirConditionerControlScreen extends StatefulWidget {
  final String brand;

  const AirConditionerControlScreen({required this.brand, super.key});

  @override
  State<AirConditionerControlScreen> createState() => _AirConditionerControlScreenState();
}

class _AirConditionerControlScreenState extends State<AirConditionerControlScreen> {
  
  late String deviceBrandCombo;

  @override
  void initState() {
    super.initState();
    deviceBrandCombo = 'Air Conditioner - ${widget.brand}';
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = (MediaQuery.of(context).size.width - 60) / 3;
    const double buttonHeight = 50.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable back button
        backgroundColor: const Color(0xFF222222), // Custom app bar color
        title: Text(
          'Control $deviceBrandCombo', // Title with brand name
          style: const TextStyle(color: Colors.white), // Text color
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              MyDevicesManager().isFavorite(deviceBrandCombo) ? Icons.favorite : Icons.favorite_border,
              color: MyDevicesManager().isFavorite(deviceBrandCombo) ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                MyDevicesManager().toggleFavorite(deviceBrandCombo);
            });
            }
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF222222), // Custom background color
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularButton(context, buttonWidth/2, 'Power', Icons.power_settings_new, Colors.red), // Power button
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircularButton(context, buttonWidth / 2, 'Mode', Icons.ac_unit, Colors.white), // Example button
                  const SizedBox(height: 8.0),
                  _buildCircularButton(context, buttonWidth / 2, 'Set', Icons.settings, Colors.white), // Example button
                  ],
                ),
            _buildCapsuleButton(context, buttonWidth / 2 + 20.0, buttonHeight * 4, 'Temperature Up', Icons.arrow_drop_up, 'Temperature Down', Icons.arrow_drop_down, Colors.white,
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircularButton(context, buttonWidth / 2, 'Fan', Icons.air, Colors.white), // Example button
                  const SizedBox(height: 8.0),
                  _buildCircularButton(context, buttonWidth / 2, 'OK', Icons.check, Colors.white), // Example button
                  ],
                ),
            ],
          ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRoundedRectangularButton(context, buttonWidth*1.5, buttonHeight, 'Timer On', Icons.timer, Colors.white), // Timer On button
                const SizedBox(width: 20.0),
                _buildRoundedRectangularButton(context, buttonWidth*1.5, buttonHeight, 'Timer Off', Icons.timer_off, Colors.white), // Timer Off button
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRoundedRectangularButton(context, buttonWidth*1.5, buttonHeight, 'H. Swing', Icons.compare_arrows_sharp, Colors.white), // Timer On button
                const SizedBox(width: 20.0),
                _buildRoundedRectangularButton(context, buttonWidth*1.5, buttonHeight, 'V. Swing', Icons.keyboard_double_arrow_up_sharp, Colors.white), // Timer Off button
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectorControlScreen extends StatefulWidget {
  final String brand;

  const ProjectorControlScreen({required this.brand, super.key});

  @override
  State<ProjectorControlScreen> createState() => _ProjectorControlScreenState();
}

class _ProjectorControlScreenState extends State<ProjectorControlScreen> {

    late String deviceBrandCombo;

    @override
    void initState() {
      super.initState();
      deviceBrandCombo = 'Projector - ${widget.brand}';
    }

    @override
    Widget build(BuildContext context) {

      const double circularButtonSize = 64.0;
      const double capsuleButtonWidth = 80.0;
      const double capsuleButtonHeight = 160.0;
      final double roundedRectangularButtonWidth= (MediaQuery.of(context).size.width - 60) / 3;
      const double roundedRectangularButtonHeight = 50.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //  back button
        backgroundColor: const Color(0xFF222222), // Set AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color
        title: Text(
          'Control $deviceBrandCombo', // Display deviceName and brand in title
          style: const TextStyle(color: Colors.white), // Set AppBar text color
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              MyDevicesManager().isFavorite(deviceBrandCombo) ? Icons.favorite : Icons.favorite_border,
              color: MyDevicesManager().isFavorite(deviceBrandCombo) ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                MyDevicesManager().toggleFavorite(deviceBrandCombo);
            });
            }
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF222222),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              Column(
                  children: [
                    _buildCircularButton(context, circularButtonSize, 'Power', Icons.power_settings_new, Colors.blue),
                    const SizedBox(height: 16),
                    _buildCircularButton(context, circularButtonSize, 'Mute', Icons.volume_off, Colors.white),
                  ],
              ),
            _buildCapsuleButton(
                context,
                capsuleButtonWidth,
                capsuleButtonHeight,
                'Volume Up',
                Icons.volume_up,
                'Volume Down',
                Icons.volume_down,
                Colors.white,
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    _buildCircularButton(context, circularButtonSize, 'Back', Icons.keyboard_backspace_rounded , Colors.white),
                    const SizedBox(height: 16),
                    _buildCircularButton(context, circularButtonSize, 'Home', Icons.home_filled , Colors.white),
                  ],
                ),
            ],
          ),
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildConcentricCircleButton(context, 240.0, Colors.white),
                ],
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(context, circularButtonSize, 'Menu', Icons.menu , Colors.white),
                    _buildCircularButton(context, circularButtonSize, 'Source', Icons.electrical_services_rounded , Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildRoundedRectangularButton(context, roundedRectangularButtonWidth, roundedRectangularButtonHeight, 'Rewind', Icons.fast_rewind_sharp, Colors.white),
                  _buildRoundedRectangularButton(context, roundedRectangularButtonWidth, roundedRectangularButtonHeight, 'Play/Pause', Icons.pause, Colors.white),
                  _buildRoundedRectangularButton(context, roundedRectangularButtonWidth, roundedRectangularButtonHeight, 'Forward', Icons.fast_forward_sharp, Colors.white),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
class CustomDeviceControlScreen extends StatelessWidget {

  final String brand;

  const CustomDeviceControlScreen({required this.brand, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //  back button
        backgroundColor: const Color(0xFF222222), // Set AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color
        title: const Text(
          'Control', // Display deviceName and brand in title
          style: TextStyle(color: Colors.white), // Set AppBar text color
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add specific controls for TV here
            Text('Controls Here'),
          ],
        ),
      ),
    );
  }
}
*/
void _showKeypad(BuildContext context) {
showModalBottomSheet(
  context: context,
  builder: (context) {
    return Container(
      color: const Color(0xFF222222),
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              for (int i = 1; i <= 9; i++)
                _buildKeypadButton(context, i, getLabel(i)),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 3,
              ),
              _buildKeypadButton(context, 0, getLabel(0)),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildKeypadButton(BuildContext context, int number, String label) {
  return SizedBox(
    width: (MediaQuery.of(context).size.width - 64) / 3,
    child: Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Add functionality for number buttons
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            backgroundColor: const Color(0xFF454545),
            foregroundColor: Colors.white,
          ),
          child: Text('$number', style: const TextStyle(fontSize: 24.0)),
        ),
        Text(label, style: const TextStyle(color: Colors.orange)),
      ],
    ),
  );
}

String getLabel(int number) {
  const labels = ['@', 'ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQRS', 'TUV', 'WXYZ', '.,#'];
  if (number >= 1 && number <= 9) {
    return labels[number - 1];
  } else if (number == 0) {
    return labels[9];
  } else {
    return '';
  }
}

Widget _buildCircularButton(BuildContext context, double size, String label, IconData icon, Color color) {
  return Column(
    children: [
      SizedBox(
        width: size,
        height: size,
        child: ElevatedButton(
          onPressed: () {
            // Add functionality for each button
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8.0),
            shape: const CircleBorder(),
            backgroundColor: const Color(0xFF454545),
            foregroundColor: color,
          ),
          child: Icon(icon, size: 32.0, color: color),
        ),
      ),
      const SizedBox(height: 4.0),
      Text(label, style: TextStyle(color: color)),
    ],
  );
}

Widget _buildCapsuleButton(BuildContext context, double width, double height, String label1, IconData icon1, String label2, IconData icon2, Color color) {
  return Column(
    children: [
      Text(label1, style: TextStyle(color: color)),
      const SizedBox(height: 4),
      SizedBox(
        width: width,
        height: height / 2,
        child: ElevatedButton(
          onPressed: () {
            // Add functionality for top button
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
            ),
            backgroundColor: const Color(0xFF454545),
            foregroundColor: color,
          ),
          child: Icon(icon1, size: 32.0, color: color),
        ),
      ),
      SizedBox(
        width: width,
        height: height / 2,
        child: ElevatedButton(
          onPressed: () {
            // Add functionality for bottom button
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.0)),
            ),
            backgroundColor: const Color(0xFF454545),
            foregroundColor: color,
          ),
          child: Icon(icon2, size: 32.0, color: color),
        ),
      ),
      const SizedBox(height: 4.0),
      Text(label2, style: TextStyle(color: color)),
    ],
  );
}

Widget _buildConcentricCircleButton(BuildContext context, double size, Color color) {
return Column(
  children: [
    Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF454545),
          ),
        ),
        Positioned(
          top: 0,
          child: _buildArrowButton(context, Icons.arrow_drop_up, color, () {
            // Add functionality for up arrow
          }),
        ),
        Positioned(
          bottom: 0,
          child: _buildArrowButton(context, Icons.arrow_drop_down, color, () {
            // Add functionality for down arrow
          }),
        ),
        Positioned(
          left: 0,
          child: _buildArrowButton(context, Icons.arrow_left, color, () {
            // Add functionality for left arrow
          }),
        ),
        Positioned(
          right: 0,
          child: _buildArrowButton(context, Icons.arrow_right, color, () {
            // Add functionality for right arrow
          }),
        ),
        SizedBox(
          width: size/2, // Adjust width as needed
          height: size/2, // Adjust height as needed
          child: ElevatedButton(
            onPressed: () {
              // Add functionality for the OK button
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8.0),
              backgroundColor: const Color(0xFF333333), // Adjust color as needed
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4.0),
    ],
  );
}


Widget _buildArrowButton(BuildContext context, IconData icon, Color color, VoidCallback onPressed) {
  return SizedBox(
    width: 48.0,
    height: 48.0,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8.0),
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF454545),
        foregroundColor: color,
      ),
      child: Icon(icon, size: 24.0, color: color),
    ),
  );
}

Widget _buildRoundedRectangularButton(BuildContext context,double btnWidth, double btnHeight, String label, IconData icon, Color color) {

  return SizedBox(
    width: btnWidth,
    height: btnHeight,
    child: ElevatedButton(
      onPressed: () {
        // Add functionality for each button
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        backgroundColor: const Color(0xFF454545),
        foregroundColor: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8.0),
          Text(label, style: TextStyle(fontSize: 14.0, color: color)),
        ],
      ),
    ),
  );
}
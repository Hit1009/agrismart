import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Data Viewer',
      home: DataViewer(),
    );
  }
}

class DataViewer extends StatefulWidget {
  @override
  _DataViewerState createState() => _DataViewerState();
}

class _DataViewerState extends State<DataViewer> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  bool isPumpOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Data Viewer'),
      ),
      body: Container(
        color: Colors.green.shade200,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: databaseReference.onValue,
                builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasData) {
                    Map? data = snapshot.data!.snapshot.value as Map?;
                    return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      children: [
                        Card(
                          color: Colors.blue.shade100,
                          child: Center(child: Text('Humidity: ${(data?['Humidity'] ?? 0.0).toDouble()}%')),
                        ),
                        Card(
                          color: Colors.purple.shade100,
                          child: Center(
                            child: Text(
                              (data?['Motion'] ?? 0.0).toDouble() == 1.0 ? 'Motion Detected' : 'Safe',
                              style: TextStyle(
                                color: (data?['Motion'] ?? 0.0).toDouble() == 1.0 ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.orange.shade100,
                          child: Center(
                            child: Text(
                              'Soil Moisture: ${(data?['Soil_Moisture'] ?? 0.0).toDouble()}%',
                              style: TextStyle(
                                color: getSoilMoistureColor((data?['Soil_Moisture'] ?? 0.0).toDouble()),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.red.shade100,
                          child: Center(child: Text('Temperature: ${(data?['Temperature'] ?? 0.0).toDouble()}°C')),
                        ),
                        Card(
                          color: Colors.green.shade100,
                          child: Center(child: Text('water_volume: ${(data?['water_volume'] ?? 0.0).toDouble()} mL')),
                        ),
                      ],
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Card(
              color: Colors.yellow.shade100,
              child: SwitchListTile(
                title: Text('Pump'),
                value: isPumpOn,
                onChanged: (bool value) {
                  setState(() {
                    isPumpOn = value;
                    databaseReference.child('pump').set(value ? 'on' : 'off');
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getSoilMoistureColor(double moisture) {
    if (moisture < 30) return Colors.red;
    if (moisture >= 30 && moisture <= 70) return Colors.blue;
    return Colors.blue;
  }
}
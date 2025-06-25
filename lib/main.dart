import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:musalud/plugins/zoombuttons_plugin.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:normal/normal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bulleted_list/bulleted_list.dart';
import 'package:tab_container/tab_container.dart';

void main()
{
  LicenseRegistry.addLicense(() async* {
    final musaludLicense = await rootBundle.loadString('assets/licenses/musalud_license.txt');
    yield LicenseEntryWithLineBreaks(['Musalud'], musaludLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final flutterMapLicense = await rootBundle.loadString('assets/licenses/flutter_map_license.txt');
    yield LicenseEntryWithLineBreaks(['flutter_map'], flutterMapLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final latlongLicense = await rootBundle.loadString('assets/licenses/latlong_license.txt');
    yield LicenseEntryWithLineBreaks(['latlong'], latlongLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final urlLauncherLicense = await rootBundle.loadString('assets/licenses/url_launcher_license.txt');
    yield LicenseEntryWithLineBreaks(['url_launcher'], urlLauncherLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final flutterLocalizationLicense = await rootBundle.loadString('assets/licenses/flutter_localization_license.txt');
    yield LicenseEntryWithLineBreaks(['flutter_localization'], flutterLocalizationLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final flutterSpinboxLicense = await rootBundle.loadString('assets/licenses/flutter_spinbox_license.txt');
    yield LicenseEntryWithLineBreaks(['flutter_spinbox'], flutterSpinboxLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final confirmDialogLicense = await rootBundle.loadString('assets/licenses/confirm_dialog_license.txt');
    yield LicenseEntryWithLineBreaks(['confirm_dialog'], confirmDialogLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final fluttertoastLicense = await rootBundle.loadString('assets/licenses/fluttertoast_license.txt');
    yield LicenseEntryWithLineBreaks(['fluttertoast'], fluttertoastLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final normalLicense = await rootBundle.loadString('assets/licenses/normal_license.txt');
    yield LicenseEntryWithLineBreaks(['normal'], normalLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final flChartLicense = await rootBundle.loadString('assets/licenses/fl_chart_license.txt');
    yield LicenseEntryWithLineBreaks(['fl_chart'], flChartLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final pathProviderLicense = await rootBundle.loadString('assets/licenses/path_provider_license.txt');
    yield LicenseEntryWithLineBreaks(['path_provider'], pathProviderLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final bulletedListLicense = await rootBundle.loadString('assets/licenses/bulleted_list_license.txt');
    yield LicenseEntryWithLineBreaks(['bulleted_list'], bulletedListLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final tabContainerLicense = await rootBundle.loadString('assets/licenses/tab_container_license.txt');
    yield LicenseEntryWithLineBreaks(['tab_container'], tabContainerLicense);
  });

  runApp(const SoilsMonitoringApp());
}

class SoilsMonitoringApp extends StatefulWidget {

  const SoilsMonitoringApp({super.key});

  @override
  State<SoilsMonitoringApp> createState() => _SoilsMonitoringAppState();
}

class _SoilsMonitoringAppState extends State<SoilsMonitoringApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: AppNavigation(dataStorage: DataStorage()),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
    );
  }
}

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key, required this.dataStorage});

  final DataStorage dataStorage;

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int month = 1;
  int year = 2025;
  static const int maxHealthIndexesDisplayed = 5;

  static const double devCot = 1.34;
  static const double devPh1 = 0.31;
  static const double devPh2 = 0.32;
  static const double devAi = 0.55;
  static const double devRsp = 0.32;
  static const double devCbm = 101.04;
  static const double devCpf = 7.59;
  static const double devApf = 60.96;
  static const double devMpr = 0.93;
  static const double devRf = 19.9;
  static const double devRsimilis = 9031;

  static const double avgCot = 3.73;
  static const double avgPh1 = 5.04;
  static const double avgPh2 = 5.89;
  static const double avgAi = 1.01;
  static const double avgRsp = 0.55;
  static const double avgCbm = 196.86;
  static const double avgCpf = 78.8;
  static const double avgApf = 195.99;
  static const double avgMpr = 7.6;
  static const double avgRf = 36.2;
  static const double avgRsimilis = 9811.2;

  static final Normal distCot = Normal(avgCot, devCot * devCot);
  static final Normal distPh1 = Normal(avgPh1, devPh1 * devPh1);
  static final Normal distPh2 = Normal(avgPh2, devPh2 * devPh2);
  static final Normal distAi = Normal(avgAi, devAi * devAi);
  static final Normal distRsp = Normal(avgRsp, devRsp * devRsp);
  static final Normal distCbm = Normal(avgCbm, devCbm * devCbm);
  static final Normal distCpf = Normal(avgCpf, devCpf * devCpf);
  static final Normal distApf = Normal(avgApf, devApf * devApf);
  static final Normal distMpr = Normal(avgMpr, devMpr * devMpr);
  static final Normal distRf = Normal(avgRf, devRf * devRf);
  static final Normal distRsimilis = Normal(avgRsimilis, devRsimilis * devRsimilis);

  int currentPageIndex = 0;
  List<Location> locations = List<Location>.empty(growable: true);

  late TextEditingController locationController;
  late TextEditingController selectedLocationController;
  late TextEditingController nameController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  late double cot;
  late double ph;
  late double ai;
  late double rsp;
  late double cbm;
  late double cpf;
  late double apf;
  late double mpr;
  late double rf;
  late double rsimilis;

  late TextEditingController scoreCotController;
  late TextEditingController scorePhController;
  late TextEditingController scoreAiController;
  late TextEditingController scoreRspController;
  late TextEditingController scoreCbmController;
  late TextEditingController scoreCpfController;
  late TextEditingController scoreApfController;
  late TextEditingController scoreMprController;
  late TextEditingController scoreRfController;
  late TextEditingController scoreRsimilisController;
  late TextEditingController overallIndexController;

  late FToast fToast;

  late List<FlSpot> chartSpots = List<FlSpot>.empty(growable: true);

  late LineChartBarData lineBarsData;

  @override
  void initState() {
    super.initState();

    locationController = TextEditingController();
    selectedLocationController = TextEditingController();
    nameController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();

    scoreCotController = TextEditingController();
    scorePhController = TextEditingController();
    scoreAiController = TextEditingController();
    scoreRspController = TextEditingController();
    scoreCbmController = TextEditingController();
    scoreCpfController = TextEditingController();
    scoreApfController = TextEditingController();
    scoreMprController = TextEditingController();
    scoreRfController = TextEditingController();
    scoreRsimilisController = TextEditingController();
    overallIndexController = TextEditingController();

    lineBarsData = lineChartBarData(getSpots());

    HealthIndex? healthIndex;
    widget.dataStorage.readLocationsFromCache().then((value) {
      setState(() {
        locations = value;

        if (locations.isNotEmpty) {
          var location = locations.first;

          locationController.text = location.name??"";
          selectedLocationController.text = location.name??"";
          latitudeController.text = location.latitude!.toStringAsFixed(6);
          longitudeController.text = location.longitude!.toStringAsFixed(6);

          if (location.healthIndexes!.isNotEmpty) {
            healthIndex = location.healthIndexes!.last;
          }
        }

        setParameters(healthIndex);
        lineBarsData = lineChartBarData(getSpots());
      });
    });

    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    locationController.dispose();
    selectedLocationController.dispose();
    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    scoreCotController.dispose();
    scorePhController.dispose();
    scoreAiController.dispose();
    scoreRspController.dispose();
    scoreCbmController.dispose();
    scoreCpfController.dispose();
    scoreApfController.dispose();
    scoreMprController.dispose();
    scoreRfController.dispose();
    scoreRsimilisController.dispose();
    overallIndexController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.green,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Principal',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on),
            label: 'Mis Localidades',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_sharp),
            label: 'Metodología Usada',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        Stack(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/suelos.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: null,
              ),
              const Align(
                  alignment: Alignment(0, 0.55),
                  child: Text(
                      'Musalud', style: TextStyle(fontSize: 50.0, color: Color(0xFF00955D), fontWeight: FontWeight.bold)
                  )
              ),
              Align(
                alignment: const Alignment(0, 0.68),
                child: ElevatedButton(
                    child: const Text('Acerca de'),
                    onPressed: ()  {
                      showAboutDialog(
                        context: context,
                        applicationIcon: const FlutterLogo(),
                        applicationName: 'Musalud',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '\u{a9} ${DateTime.now().year} Jose Pablo Vargas & Olger Vargas',
                        children: [
                          const Text(''),
                          const Text('Musalud es una aplicación de uso libre que proporciona recomendaciones para mejorar la calidad del suelo en cultivos de banano.'),
                          const Text(''),
                          const Text("(Musalud is a free use application that provides recommendations to improve soil's health in banana plantations.)"),
                        ]
                      );
                    },
                  ),
              )
            ]
        ),

        /// Locations page
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40.0,
              ),
              Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        child: DropdownMenu<String>(
                          label: Text(locations.isEmpty ? "Agregue una Localidad..." : "Localidad",),
                          requestFocusOnTap: true,
                          width: 500,
                          enableSearch: true,
                          hintText: locations.isEmpty ? "Agregue una Localidad..." : "Seleccione una Localidad...",
                          controller: selectedLocationController,
                          onSelected: (String? value) {
                            setState(() {
                              locationController.text = value!;
                              lineBarsData = lineChartBarData(getSpots());
                            });
                          },
                          dropdownMenuEntries: locations
                              .map((location) =>
                              DropdownMenuEntry(value: location.name??"", label: location.name??""))
                              .toList(),
                        )
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(bottom: 5, top: 0, left: 10, right: 10),
                                child: FloatingActionButton(
                                  heroTag: 'addLocationButton',
                                  mini: true,
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.deepPurpleAccent,
                                  onPressed: () async {
                                    latitudeController.text = "9.630189";
                                    longitudeController.text = "-84.254184";
                                    final location = await openAddLocationDialog(latitudeController.text, longitudeController.text);
                                    if (location == null) return;
                                    setState(() {
                                      locations.add(location);
                                      lineBarsData = lineChartBarData(getSpots());
                                      widget.dataStorage.writeLocationsToCache(locations);
                                    });
                                  },
                                  child: const Icon(Icons.add_box),
                                )
                            ),
                            if (locationController.text.isNotEmpty)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 5, top: 0, left: 10, right: 10),
                                  child: FloatingActionButton(
                                    heroTag: 'deleteLocationButton',
                                    mini: true,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.deepPurpleAccent,
                                    onPressed: () async {
                                      if (await confirm(
                                        context,
                                        title: const Text('Confirmación'),
                                        content: Text('Desea eliminar ${locationController.text} y toda su información, incluidos parámetros e índices de calidad y salud?'),
                                        textOK: const Text('Sí'),
                                        textCancel: const Text('No'),
                                      )) {
                                        setState(() {
                                          String locationToRemove = locationController.text;
                                          locations.removeAt(locations.indexWhere((location) => location.name == locationToRemove));
                                          locationController.text = locations.firstOrNull == null ? "" : locations.first.name??"";
                                          selectedLocationController.text = locations.firstOrNull == null ? "" : locations.first.name??"";
                                          lineBarsData = lineChartBarData(getSpots());
                                          widget.dataStorage.writeLocationsToCache(locations);
                                          showToast('$locationToRemove ha sido eliminada exitosamente', Colors.red, 3, ToastGravity.TOP,
                                              const Icon(Icons.check, color: Colors.white,));
                                        });
                                      }
                                      return;
                                    },
                                    child: const Icon(Icons.indeterminate_check_box),
                                  )
                              ),
                            if (locationController.text.isNotEmpty)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 5, top: 0, left: 10, right: 10),
                                  child: FloatingActionButton(
                                    heroTag: 'calculateHealthIndexButton',
                                    mini: true,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.deepPurpleAccent,
                                    onPressed: () async {
                                      setParameters(null);
                                      startHealthIndexCalculation();
                                    },
                                    child: const Icon(Icons.calculate),
                                  )
                              ),
                            if (locationController.text.isNotEmpty)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 5, top: 0, left: 10, right: 10),
                                  child: FloatingActionButton(
                                    heroTag: 'viewHealthIndexesButton',
                                    mini: true,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.deepPurpleAccent,
                                    onPressed: () async {
                                      await openViewHealthIndexes();
                                    },
                                    child: const Icon(Icons.history_toggle_off),
                                  )
                              )
                          ]
                      ),
                    )
                  ]
              ),
              SizedBox(
                  height: 280,
                  width: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      interactionOptions: const InteractionOptions(
                        enableMultiFingerGestureRace: true,
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      initialCenter: const LatLng(9.630189, -84.254184), // Center the map over Costa Rica
                      initialZoom: 7,
                      minZoom: 4,
                      maxZoom: 18,
                      keepAlive: true,
                      cameraConstraint: CameraConstraint.contain(
                        bounds: LatLngBounds(
                          const LatLng(7.826057, -86.019564),
                          const LatLng(11.350769, -82.361173),
                        ),
                      ),
                      onTap: (_, p) async {
                        latitudeController.text = p.latitude.toStringAsFixed(6);
                        longitudeController.text = p.longitude.toStringAsFixed(6);
                        final location = await openAddLocationDialog(latitudeController.text, longitudeController.text);
                        if (location == null) return;
                        setState(() {
                          locations.add(location);
                          lineBarsData = lineChartBarData(getSpots());
                          widget.dataStorage.writeLocationsToCache(locations);
                        });
                      },
                    ),
                    children: [
                      TileLayer( // Display map tiles from any source
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                        maxNativeZoom: 18, // Scale tiles when the server doesn't support higher zoom levels
                      ),
                      MarkerLayer(
                          markers: locations.map((location) => getMarker(location)).toList()
                      ),

                      RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirements
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                            onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                          ),
                          // Also add images...
                        ],
                      ),
                      const FlutterMapZoomButtons(
                        minZoom: 1,
                        maxZoom: 18,
                        mini: true,
                        padding: 10,
                        alignment: Alignment.bottomRight,
                      )
                    ],
                  )
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Histórico de Calidad y Salud de ${locationController.text}',
                      style: const TextStyle(
                        fontSize: 15,)
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 30,
                      left: 15,
                      top: 5,
                      bottom: 5,
                    ),
                    child: LineChart(
                      linearChartData(),
                    ),
                  ),
                ),
              ),
            ]
        ),

        /// Methodologies page
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50.0,
              ),
              SizedBox(
                width: 400,
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
                  child: TabContainer(
                    color: Theme.of(context).colorScheme.primary,
                    tabEdge: TabEdge.left,
                      tabExtent: 100.0,
                    tabsStart: 0.1,
                    tabsEnd: 0.9,
                    childPadding: const EdgeInsets.all(20.0),
                    tabs: const <Widget>[
                      Text('COT'),
                      Text('pH'),
                      Text('AI'),
                      Text('CBM'),
                      Text('RSP'),
                      Text('CPF'),
                      Text('APF'),
                      Text('MPR'),
                      Text('RF'),
                      Text('R.similis')
                    ],
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                    ),
                    unselectedTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Profundidad de muestra 0-30 cm frente a hijo de sucesión.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 50.0),
                            Text(
                              'Metodología de análisis',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Combustión seca.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Profundidad de muestra 0-30 cm frente a hijo de sucesión.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 50.0),
                            Text(
                              'Metodología de análisis',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'En agua.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Profundidad de muestra 0-30 cm frente a hijo de sucesión.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 50.0),
                            Text(
                              'Metodología de análisis',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'En KCl 1M.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Profundidad de muestra 0-30 cm frente a hijo de sucesión.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 50.0),
                            Text(
                              'Metodología de análisis',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Fumigación-extracción. Vance et al. (1987).',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Superficial, humedad a capacidad de campo, utilizando un penetrómetro marca Eijkelkamp® modelo 06.01SB.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Planta en edad de parición. Circunferencia a 1 m de altura.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Hijo de planta en edad de parición. Altura del hijo de sucesión, de la base a la "v" que se forma entre la hoja candela y hoja #1.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Conteo de manos en frutas de 11 o 12 semanas de embolse.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Muestra tomada en un volumen de suelo de 13x13x30 cm, entre madre e hijo de sucesión.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 50.0),
                            Text(
                              'Metodología de análisis',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Metodología descrita por Vargas y Araya (2018)',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metodología de muestreo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Muestra tomada en un volumen de suelo de 13x13x30 cm, entre madre e hijo de sucesión.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 50.0),
                            Text(
                              'Metodología de análisis',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Metodología descrita por Vargas y Araya (2018)',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ]
        )
      ][currentPageIndex],
    );
  }

  void showToast(String message, Color color, int duration, ToastGravity toastGravity, Icon icon){
    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: color,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(
              width: 12.0,
            ),
            Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                )
            ),
          ],
        ),
      ),
      gravity: toastGravity,
      toastDuration: Duration(seconds: duration),
    );
  }

  Future<void> startHealthIndexCalculation() async {
    final healthIndex = await openCalculateHealthIndexDialog();
    if (healthIndex == null) return;
    setState(() {
      var selectedLocation = locations.where((location) => location.name == locationController.text).first;
      if (selectedLocation.healthIndexes!.any((hi) => hi.year == healthIndex.year && hi.month == healthIndex.month))
      {
        int i = selectedLocation.healthIndexes!.indexWhere((hi) => hi.year == healthIndex.year && hi.month == healthIndex.month);
        selectedLocation.healthIndexes![i] = healthIndex;
      }
      else
      {
        selectedLocation.healthIndexes!.add(healthIndex);
      }

      //selectedLocation.marker = setMarker(selectedLocation.latitude??0, selectedLocation.longitude??0, selectedLocation.name, healthIndex.index);
      lineBarsData = lineChartBarData(getSpots());

      widget.dataStorage.writeLocationsToCache(locations);
    });

    showToast('El índice ha sido calculado exitosamente!', Colors.green, 3, ToastGravity.TOP, const Icon(Icons.check, color: Colors.white,));
  }

  List<HealthIndex> getLastHealthIndexes(int? count) {
    List<HealthIndex> lastHealthIndexes = List<HealthIndex>.empty();
    if (locationController.text.isNotEmpty) {
      var location = locations.firstWhere((location) => location.name == locationController.text);
      if (location.healthIndexes!.isNotEmpty) {
        if (count != null) {
          lastHealthIndexes = location.healthIndexes!.reversed
              .take(count)
              .toList()
              .reversed
              .toList();
        }
        else {
          lastHealthIndexes = location.healthIndexes!;
        }
      }
    }
    return lastHealthIndexes;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text = const Text("");

    var lastHealthIndexes = getLastHealthIndexes(maxHealthIndexesDisplayed);
    if (value < lastHealthIndexes.length) {
      int i = value.toInt();
      var healthIndex = lastHealthIndexes[i];
      text = Text(
          '${getShortMonth(healthIndex.month??0)}\n${healthIndex.year??0}',
          softWrap: true,
          style: style,
          textAlign: TextAlign.center
      );
    }

    return SideTitleWidget(
        axisSide: meta.axisSide,
        child: SizedBox(
          width: 35,
          child: text,
        )
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 25:
        text = '25%';
        break;
      case 50:
        text = '50%';
        break;
      case 75:
        text = '75%';
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  String getShortMonth(int month) {
    switch (month) {
      case 1:
        return 'ENE';
      case 2:
        return 'FEB';
      case 3:
        return 'MAR';
      case 4:
        return 'ABR';
      case 5:
        return 'MAY';
      case 6:
        return 'JUN';
      case 7:
        return 'JUL';
      case 8:
        return 'AGO';
      case 9:
        return 'SEP';
      case 10:
        return 'OCT';
      case 11:
        return 'NOV';
      case 12:
        return 'DIC';
      default:
        return '';
    }
  }

  String getMonth(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  List<FlSpot> getSpots() {
    List<FlSpot> spots = List<FlSpot>.empty(growable: true);

    var lastHealthIndexes = getLastHealthIndexes(maxHealthIndexesDisplayed);

    double i = 0;
    for (var healthIndex in lastHealthIndexes) {
      spots.add(FlSpot(i, healthIndex.index??0));
      i++;
    }

    return spots;
  }

  LineChartBarData lineChartBarData(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.grey,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          Color color = spot.y > 65 ? Colors.green :
                        spot.y > 35 ? Colors.lightGreen :
                        spot.y > 10 ? Colors.amber :
                        Colors.red;
          return FlDotCirclePainter(
            radius: 13,
            color: color,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
    );
  }

  LineChartData linearChartData() {
    var healthIndexes = List<HealthIndex>.empty(growable: true);
    if (locationController.text.isNotEmpty) {
      var location = locations.firstWhere((location) => location.name == locationController.text);
      if (location.healthIndexes != null) {
        healthIndexes = location.healthIndexes!;
      }
    }
    return LineChartData(
      showingTooltipIndicators: healthIndexes.take(5).toList().asMap().keys
          .map((index) {
        return ShowingTooltipIndicators([
          LineBarSpot(
            lineBarsData,
            0,
            lineBarsData.spots[index],
          ),
        ]);
      }).toList(),
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 60,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 4,
      minY: 0,
      maxY: 100,
      lineBarsData: [lineBarsData],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) => Colors.transparent,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              return LineTooltipItem(
                '${lineBarSpot.y.toStringAsFixed(2)} %',
                const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            }).toList();
          },
        ),
        touchCallback:
            (FlTouchEvent event, LineTouchResponse? response) async {
          if (response == null || response.lineBarSpots == null) {
            return;
          }
          if (event is FlTapUpEvent) {
            final spotIndex = response.lineBarSpots!.first.spotIndex;
            var lastHealthIndexes = getLastHealthIndexes(maxHealthIndexesDisplayed);
            var healthIndex = lastHealthIndexes[spotIndex];
            setParameters(healthIndex);
            if (healthIndex.year == DateTime.now().year && healthIndex.month == DateTime.now().month) {
              startHealthIndexCalculation();
            }
            else {
              await openViewHealthIndexDialog(healthIndex);
            }
          }
        },
      ),
    );
  }

  Future<Location?> openAddLocationDialog(String latitude, String longitude) => showDialog<Location>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Nueva Localidad"),
      content: Column(
        children: [
          Form(
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              autofocus: true,
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Nombre",
                labelText: "Nombre",
              ),
              validator: (text) => text!.isEmpty ? 'Required' : null,
              autovalidateMode: AutovalidateMode.always,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SpinBox(
              min: 8,
              max: 11.2,
              value: double.parse(latitude),
              decimals: 6,
              step: 0.000001,
              acceleration: 0.01,
              decoration: const InputDecoration(
                hintText: 'Latitud',
                labelText: 'Latitud',
              ),
              validator: (text) => text!.isEmpty ? 'Required' : null,
              onChanged: (latitude) {
                latitudeController.text = latitude.toString();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SpinBox(
              min: -85.9,
              max: -82.5,
              value: double.parse(longitude),
              decimals: 6,
              step: 0.000001,
              acceleration: 0.01,
              decoration: const InputDecoration(
                hintText: 'Longitud',
                labelText: 'Longitud',
              ),
              validator: (text) => text!.isEmpty ? 'Required' : null,
              onChanged: (longitude) {
                longitudeController.text = longitude.toString();
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCELAR'),
        ),
        TextButton(
          onPressed: () {
            createLocation();
          },
          child: const Text('AGREGAR'),
        ),
      ],
    ),
  );

  Future<HealthIndex?> openCalculateHealthIndexDialog() => showDialog<HealthIndex>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      title: Text('Cálculo de Índice de Calidad y Salud de ${locationController.text} - ${getMonth(DateTime.now().month)}, ${DateTime.now().year}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      content: Wrap(
        children: [
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          textAlign: TextAlign.center,
                          min: 0,
                          max: 5,
                          value: ai,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'AI',
                              labelText: 'AI (cmol(+) L-1)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            ai = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreAiController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 8,
                          value: ph,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'pH',
                              labelText: 'pH',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            ph = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scorePhController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 2,
                          value: rsp,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'RSP',
                              labelText: 'RSP (MPa)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            rsp = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreRspController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 11,
                          value: cot,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'COT',
                              labelText: 'COT (%)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            cot = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreCotController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 120,
                          value: cpf,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'CPF',
                              labelText: 'CPF (cm)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            cpf = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreCpfController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 500,
                          value: apf,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'APF',
                              labelText: 'APF (cm)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            apf = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreApfController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 4,
                          max: 12,
                          value: mpr,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'MPR',
                              labelText: 'MPR (Manos)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            mpr = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreMprController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 200,
                          value: rf,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                              hintText: 'RF',
                              labelText: 'RF (g planta-1)',
                              labelStyle: TextStyle(color: Colors.red)
                          ),
                          onChanged: (value) => setState(() {
                            rf = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreRfController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 700,
                          value: cbm,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                            hintText: 'CBM',
                            labelText: 'CBM (ug C kg^-1 suelo^-1)',
                          ),
                          onChanged: (value) => setState(() {
                            cbm = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreCbmController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 195,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: SpinBox(
                          min: 0,
                          max: 70000,
                          value: rsimilis,
                          decimals: 2,
                          step: 0.01,
                          acceleration: 0.01,
                          decoration: const InputDecoration(
                            hintText: 'R.similis.',
                            labelText: 'R.similis. (indiv 100 g-1)',
                          ),
                          onChanged: (value) => setState(() {
                            rsimilis = value;
                            calculateHealthIndex();
                          }),
                          validator: (text) => text!.isEmpty ? 'Required' : null,
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.center,
                          controller: scoreRsimilisController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
              child:TextField(
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  readOnly: true,
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.center,
                  controller: overallIndexController,
                  decoration:  const InputDecoration(
                    prefixText: 'ÍNDICE: ',
                    suffixText: '%',
                  )
              )
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCELAR'),
        ),
        TextButton(
          onPressed: () {
            if (scoreAiController.text.isEmpty || scoreApfController.text.isEmpty
                || scoreCotController.text.isEmpty || scoreCpfController.text.isEmpty
                || scoreMprController.text.isEmpty || scoreMprController.text.isEmpty
                || scoreRfController.text.isEmpty || scoreRspController.text.isEmpty)
            {
              showToast("Los parámetros en rojo son obligatorios", Colors.orangeAccent, 2, ToastGravity.BOTTOM, const Icon(Icons.warning_amber, color: Colors.white,));
              return;
            }
            else {
              createHealthIndex();
            }
          },
          child: const Text('GUARDAR'),
        ),
      ],
    ),
  );

  Future<HealthIndex?> openViewHealthIndexDialog(HealthIndex healthIndex) => showDialog<HealthIndex>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      title: Text('Índice de Calidad y Salud de ${locationController.text} - ${getMonth(healthIndex.month??0)}, ${healthIndex.year??0}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      content: Wrap(
        children: [
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: ai.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                              hintText: 'AI',
                              labelText: 'AI (cmol(+) L-1)'
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreAiController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: ph.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                              hintText: 'pH',
                              labelText: 'pH'
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scorePhController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: rsp.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'RSP',
                            labelText: 'RSP (MPa)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreRspController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: cot.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                              hintText: 'COT',
                              labelText: 'COT (%)'
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreCotController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: cpf.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'CPF',
                            labelText: 'CPF (cm)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreCpfController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: apf.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'APF',
                            labelText: 'APF (cm)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreApfController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: mpr.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'MPR',
                            labelText: 'MPR (Manos)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreMprController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: rf.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'RF',
                            labelText: 'RF (g planta-1)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreRfController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: cbm.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'CBM',
                            labelText: 'CBM (ug C kg^-1 suelo^-1)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreCbmController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: rsimilis.toStringAsFixed(2)),
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: 'R.similis.',
                            labelText: 'R.similis. (indiv 100 g-1)',
                          ),
                        )
                    ),
                  ),
                  Expanded(child:
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 0, left: 8, right: 8),
                      child:TextField(
                          readOnly: true,
                          textAlign: TextAlign.right,
                          textAlignVertical: TextAlignVertical.bottom,
                          controller: scoreRsimilisController,
                          decoration:  const InputDecoration(
                            prefixText: 'Nota: ',
                            suffixText: '%',
                          )
                      )
                  ),
                  )
                ],
              )
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 8),
                child:TextField(
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    readOnly: true,
                    textAlign: TextAlign.right,
                    textAlignVertical: TextAlignVertical.center,
                    controller: overallIndexController,
                    decoration:  const InputDecoration(
                      prefixText: 'ÍNDICE: ',
                      suffixText: '%',
                    )
                )
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await openRecommendationsDialog(healthIndex);
          },
          child: const Text('VER RECOMENDACIONES')
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CERRAR')
        ),
      ],
    ),
  );

  Future openViewHealthIndexes() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      title: Text('Índices de Calidad y Salud de ${locationController.text}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      content:
      SizedBox(
          height: 600,
          width: 300,
          child: ListView.separated(
            itemCount: locations.firstWhere((location) => location.name == locationController.text).healthIndexes!.length,
            itemBuilder: (context, index) {
              final healthIndex = locations.firstWhere((location) => location.name == locationController.text).healthIndexes![index];
              return ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text('${getMonth(healthIndex.month??0)}, ${healthIndex.year??0}'),
                  trailing: const Icon(Icons.remove_red_eye),
                  onTap: () async { //
                    setParameters(healthIndex);//                          <-- onTap
                    await openViewHealthIndexDialog(healthIndex);
                  }
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CERRAR'),
        ),
      ],
    ),
  );

  Future<HealthIndex?> openRecommendationsDialog(HealthIndex healthIndex) => showDialog<HealthIndex>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(10),
      title: Text('Recomendaciones para ${locationController.text} - ${getMonth(healthIndex.month??0)}, ${healthIndex.year??0}', style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Container(
          height: 1400,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BulletedList(
                listItems: getUrgentRecommendations(healthIndex),
                bullet: const Icon(Icons.warning, color: Colors.red),
              ),
              BulletedList(
                listItems: getWarningRecommendations(healthIndex),
                bullet: const Icon(Icons.warning_amber, color: Colors.yellow),
              ),
              BulletedList(
                listItems: getGoodRecommendations(healthIndex),
                bullet: const Icon(Icons.check, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Align(
                alignment: Alignment.bottomRight,
                child: Text('CERRAR')
            )
        ),
      ],
    ),
  );

  void createLocation() {
    var location = Location();
    location.name = nameController.text;
    location.latitude = double.parse(latitudeController.text);
    location.longitude = double.parse(longitudeController.text);
    location.healthIndexes = List<HealthIndex>.empty(growable: true);

    if (nameController.text.isNotEmpty)
    {
      locationController.text = location.name??"";
      selectedLocationController.text = location.name??"";

      nameController.clear();
      latitudeController.clear();
      longitudeController.clear();
      Navigator.of(context).pop(location);
    }
  }

  void setParameters(HealthIndex? healthIndex){
    cot = 0;
    ph = 0;
    ai = 5;
    rsp = 2;
    cbm = 0;
    cpf = 0;
    apf = 0;
    mpr = 0;
    rf = 0;
    rsimilis = 0;

    scoreCotController.text = "";
    scorePhController.text = "";
    scoreAiController.text = "";
    scoreRspController.text = "";
    scoreCbmController.text = "";
    scoreCpfController.text = "";
    scoreApfController.text = "";
    scoreMprController.text = "";
    scoreRfController.text = "";
    scoreRsimilisController.text = "";
    overallIndexController.text = "";

    if(locationController.text.isNotEmpty){
      var location = locations.firstWhere((location) => location.name == locationController.text);
      if (location.healthIndexes!.isNotEmpty) {
        HealthIndex hi = healthIndex ?? location.healthIndexes!.last;
        cot = hi.cot??0;
        ph = hi.ph??0;
        ai = hi.ai??0;
        rsp = hi.rsp??0;
        cbm = hi.cbm??0;
        cpf = hi.cpf??0;
        apf = hi.apf??0;
        mpr = hi.mpr??0;
        rf = hi.rf??0;
        rsimilis = hi.rsimilis??0;

        scoreCotController.text = hi.scoreCot == 0 ? "" : hi.scoreCot!.toStringAsFixed(2);
        scorePhController.text = hi.scorePh == 0 ? "" : hi.scorePh!.toStringAsFixed(2);
        scoreAiController.text = hi.scoreAi == 0 ? "" : hi.scoreAi!.toStringAsFixed(2);
        scoreRspController.text = hi.scoreRsp == 0 ? "" : hi.scoreRsp!.toStringAsFixed(2);
        scoreCbmController.text = hi.scoreCbm == 0 ? "" : hi.scoreCbm!.toStringAsFixed(2);
        scoreCpfController.text = hi.scoreCpf == 0 ? "" : hi.scoreCpf!.toStringAsFixed(2);
        scoreApfController.text = hi.scoreApf == 0 ? "" : hi.scoreApf!.toStringAsFixed(2);
        scoreMprController.text = hi.scoreMpr == 0 ? "" : hi.scoreMpr!.toStringAsFixed(2);
        scoreRfController.text = hi.scoreRf == 0 ? "" : hi.scoreRf!.toStringAsFixed(2);
        scoreRsimilisController.text = hi.scoreRsimilis == 0 ? "" : hi.scoreRsimilis!.toStringAsFixed(2);

        overallIndexController.text = hi.index == 0 ? "" : hi.index!.toStringAsFixed(2);
      }
    }
  }

  void createHealthIndex() {
    var healthIndex = HealthIndex();

    healthIndex.year = DateTime.now().year;
    healthIndex.month = DateTime.now().month;

    healthIndex.cot = cot;
    healthIndex.ph = ph;
    healthIndex.ai = ai;
    healthIndex.rsp = rsp;
    healthIndex.cbm = cbm;
    healthIndex.cpf = cpf;
    healthIndex.apf = apf;
    healthIndex.mpr = mpr;
    healthIndex.rf = rf;
    healthIndex.rsimilis = rsimilis;

    healthIndex.scoreCot = scoreCotController.text.isEmpty ? 0 : double.parse(scoreCotController.text);
    healthIndex.scorePh = scorePhController.text.isEmpty ? 0 : double.parse(scorePhController.text);
    healthIndex.scoreAi = scoreAiController.text.isEmpty ? 0 : double.parse(scoreAiController.text);
    healthIndex.scoreRsp = scoreRspController.text.isEmpty ? 0 : double.parse(scoreRspController.text);
    healthIndex.scoreCbm = scoreCbmController.text.isEmpty ? 0 : double.parse(scoreCbmController.text);
    healthIndex.scoreCpf = scoreCpfController.text.isEmpty ? 0 : double.parse(scoreCpfController.text);
    healthIndex.scoreApf = scoreApfController.text.isEmpty ? 0 : double.parse(scoreApfController.text);
    healthIndex.scoreMpr = scoreMprController.text.isEmpty ? 0 : double.parse(scoreMprController.text);
    healthIndex.scoreRf = scoreRfController.text.isEmpty ? 0 : double.parse(scoreRfController.text);
    healthIndex.scoreRsimilis = scoreRsimilisController.text.isEmpty ? 0 : double.parse(scoreRsimilisController.text);

    healthIndex.index = overallIndexController.text.isEmpty ? 0 : double.parse(overallIndexController.text);

    Navigator.of(context).pop(healthIndex);
  }

  void calculateHealthIndex() {
    int parametersEntered = 0;
    double scoresSum = 0;
    overallIndexController.text = "";

    if (cot > 0) {
      var scoreCot = double.parse((distCot.cdf(cot) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreCot;
      scoreCotController.text = scoreCot.toString();
      parametersEntered++;
    }
    else {
      scoreCotController.text = "";
    }

    if (ph > 0 && ph <= 5.5) {
      var scorePh = double.parse((distPh1.cdf(ph) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scorePh;
      scorePhController.text = scorePh.toString();
      parametersEntered++;
    }
    else if (ph > 5.5 && ph <= 8) {
      var scorePh = double.parse(((1 - distPh2.cdf(ph)) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scorePh;
      scorePhController.text = scorePh.toString();
      parametersEntered++;
    }
    else {
      scorePhController.text = "";
    }

    if (ai < 5) {
      var scoreAi = double.parse(((1 - distAi.cdf(ai)) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreAi;
      scoreAiController.text = scoreAi.toString();
      parametersEntered++;
    }
    else {
      scoreAiController.text = "";
    }

    if (rsp < 2) {
      var scoreRsp = double.parse(((1- distRsp.cdf(rsp)) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreRsp;
      scoreRspController.text = scoreRsp.toString();
      parametersEntered++;
    }
    else {
      scoreRspController.text = "";
    }

    if (cbm > 0) {
      var scoreCbm = double.parse((distCbm.cdf(cbm) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreCbm;
      scoreCbmController.text = scoreCbm.toString();
      parametersEntered++;
    }
    else {
      scoreCbmController.text = "";
    }

    if (cpf > 0) {
      var scoreCpf = double.parse((distCpf.cdf(cpf) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreCpf;
      scoreCpfController.text = scoreCpf.toString();
      parametersEntered++;
    }
    else {
      scoreCpfController.text = "";
    }

    if (apf > 0) {
      var scoreApf = double.parse((distApf.cdf(apf) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreApf;
      scoreApfController.text = scoreApf.toString();
      parametersEntered++;
    }
    else {
      scoreApfController.text = "";
    }

    if (mpr > 0) {
      var scoreMpr = double.parse((distMpr.cdf(mpr) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreMpr;
      scoreMprController.text = scoreMpr.toString();
      parametersEntered++;
    }
    else {
      scoreMprController.text = "";
    }

    if (rf > 0) {
      var scoreRf = double.parse((distRf.cdf(rf) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreRf;
      scoreRfController.text = scoreRf.toString();
      parametersEntered++;
    }
    else {
      scoreRfController.text = "";
    }

    if (rsimilis > 0) {
      var scoreRsimilis = double.parse(((1 - distRsimilis.cdf(rsimilis)) * 100).toStringAsFixed(2));
      scoresSum = scoresSum + scoreRsimilis;
      scoreRsimilisController.text = scoreRsimilis.toString();
      parametersEntered++;
    }
    else {
      scoreRsimilisController.text = "";
    }

    if (parametersEntered > 0) {
      overallIndexController.text = (scoresSum / parametersEntered).toStringAsFixed(2);
    }
  }

  List<String> getUrgentRecommendations(HealthIndex healthIndex)
  {
    List<String> recommendations = [];

    if (healthIndex.cot! < 3)
    {
      recommendations.add("Bajo carbono. Aumente la incorporación de materia orgánica.");
    }
    if (healthIndex.ph! < 5 || healthIndex.ph! > 5.5)
    {
      recommendations.add("pH extremo. Realizar encalado o acidificación correctiva. Balancear la nutrición y revisar uso de fuentes nitrogenadas.");
    }
    if (healthIndex.ai! > 0.5)
    {
      recommendations.add("Alta acidez. Aplicar correctivos de acidez (ej. encalado).");
    }
    if (healthIndex.rsp! > 1)
    {
      recommendations.add("Suelo muy compactado. Implementar subsolado o labores de descompactación. Considerar el uso de coberturas vegetales.");
    }
    if (healthIndex.cbm! < 150)
    {
      recommendations.add("Baja actividad microbiana. Aplicar materia orgánica para aumentar actividad microbiana.");
    }
    if (healthIndex.cpf! < 80 || healthIndex.apf! < 150 || healthIndex.mpr! < 9)
    {
      recommendations.add("Revisar criterios de selección de deshija. Revisar sintomas de deficiencias. Reforzar nutrición edáfica y foliar.");
    }
    if (healthIndex.rf! < 75 || healthIndex.rsimilis! > 10000)
    {
      recommendations.add("Continuar monitoreo. Revisar compactación y programa de control de nemátodos y picudo.");
    }

    return recommendations;
  }

  List<String> getWarningRecommendations(HealthIndex healthIndex)
  {
    List<String> recommendations = [];

    if (healthIndex.ai! >= 0.3 && healthIndex.ai! <= 0.5)
    {
      recommendations.add("Acidez moderada. Atención.");
    }
    if (healthIndex.rsp! >= 0.7 && healthIndex.rsp! <= 1)
    {
      recommendations.add("Compactación moderada. Atención.");
    }

    return recommendations;
  }

  List<String> getGoodRecommendations(HealthIndex healthIndex)
  {
    List<String> recommendations = [];

    if (healthIndex.cot! >= 3)
    {
      recommendations.add("Buen contenido de carbono.");
    }
    if (healthIndex.ph! >= 5 && healthIndex.ph! <= 5.5)
    {
      recommendations.add("pH adecuado. Siga prácticas de fertilización balanceadas.");
    }
    if (healthIndex.ai! < 0.3)
    {
      recommendations.add("Acidez intercambiable baja.");
    }
    if (healthIndex.rsp! < 0.7)
    {
      recommendations.add("Suelo descompactado.");
    }
    if (healthIndex.cbm! >= 150)
    {
      recommendations.add("Alta actividad microbiana.");
    }
    if (healthIndex.cpf! >= 80 && healthIndex.apf! >= 150 && healthIndex.mpr! >= 9)
    {
      recommendations.add("Vigor optimo en la plantación.");
    }
    if (healthIndex.rf! >= 75 && healthIndex.rsimilis! <= 10000)
    {
      recommendations.add("Raíz funcional adecuada y baja población de nemátodos.");
    }

    return recommendations;
  }

  Marker getMarker(Location location)
  {
    Color color;
    String text;

    double? healthIndex;
    if (location.healthIndexes!.isNotEmpty)
    {
      healthIndex = location.healthIndexes!.last.index;
    }

    if (healthIndex == null) {
      color = Colors.black;
      text = '${location.name} aun no ha sido calificada con un índice';
    }
    else if (healthIndex > 65)
    {
      color = Colors.green;
      text = '${location.name} presenta un índice muy bueno de ${healthIndex.toStringAsFixed(2)}%';
    }
    else if (healthIndex > 35)
    {
      color = Colors.lightGreen;
      text = '${location.name} presenta un índice bueno de ${healthIndex.toStringAsFixed(2)}%';
    }
    else if (healthIndex > 10)
    {
      color = Colors.amber;
      text = '${location.name} presenta un índice regular de ${healthIndex.toStringAsFixed(2)}%';
    }
    else
    {
      color = Colors.red;
      text = '${location.name} presenta un índice pobre de ${healthIndex.toStringAsFixed(2)}%';
    }

    return Marker(
        point: LatLng(location.latitude??0, location.longitude??0),
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(text),
                duration: const Duration(seconds: 5),
                backgroundColor: color,
                showCloseIcon: true,
              ),
            );
            setState(() {
              locationController.text = location.name??"";
              selectedLocationController.text = location.name??"";
              lineBarsData = lineChartBarData(getSpots());
            });
          },
          child: Icon(Icons.location_pin, size: 35, color: color),
        )
    );
  }
}

class Location {
  late String? name;
  late double? latitude;
  late double? longitude;
  late List<HealthIndex>? healthIndexes;

  Location({this.name, this.latitude, this.longitude, this.healthIndexes});

  factory Location.fromJson(Map<String, dynamic> json) {
    var hIndexes = List<HealthIndex>.empty(growable: true);
    if (json["healthIndexes"] != null) {
      var hIndexesJsonDynamic = json["healthIndexes"];
      HealthIndexes healthIndexes = HealthIndexes.fromJson(hIndexesJsonDynamic);
      hIndexes = healthIndexes.list;
    }

    return Location(
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        healthIndexes: hIndexes
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "latitude": latitude,
    "longitude": longitude,
    "healthIndexes": healthIndexes
  };
}

class Locations{
  final List<Location> list;

  Locations({required this.list});

  factory Locations.fromJson(List<dynamic> json){
    List<Location> list = json.map((e) => Location.fromJson(e)).toList();
    return Locations(list: list);
  }
}

class HealthIndexes{
  final List<HealthIndex> list;

  HealthIndexes({required this.list});

  factory HealthIndexes.fromJson(List<dynamic> json){
    List<HealthIndex> list = json.map((e) => HealthIndex.fromJson(e)).toList();
    return HealthIndexes(list: list);
  }
}

class HealthIndex {
  late int? year;
  late int? month;
  late double? cot;
  late double? ph;
  late double? ai;
  late double? rsp;
  late double? cbm;
  late double? cpf;
  late double? apf;
  late double? mpr;
  late double? rf;
  late double? rsimilis;
  late double? scoreCot;
  late double? scorePh;
  late double? scoreAi;
  late double? scoreRsp;
  late double? scoreCbm;
  late double? scoreCpf;
  late double? scoreApf;
  late double? scoreMpr;
  late double? scoreRf;
  late double? scoreRsimilis;
  late double? index;

  HealthIndex({
    this.year,
    this.month,
    this.cot,
    this.ph,
    this.ai,
    this.rsp,
    this.cbm,
    this.cpf,
    this.apf,
    this.mpr,
    this.rf,
    this.rsimilis,
    this.scoreCot,
    this.scorePh,
    this.scoreAi,
    this.scoreRsp,
    this.scoreCbm,
    this.scoreCpf,
    this.scoreApf,
    this.scoreMpr,
    this.scoreRf,
    this.scoreRsimilis,
    this.index
  });

  factory HealthIndex.fromJson(Map<String, dynamic> json) {
    return HealthIndex(
        year: json['year'],
        month: json['month'],
        cot: json['cot'],
        ph: json['ph'],
        ai: json['ai'],
        rsp: json['rsp'],
        cbm: json['cbm'],
        cpf: json['cpf'],
        apf: json['apf'],
        mpr: json['mpr'],
        rf: json['rf'],
        rsimilis: json['rsimilis'],
        scoreCot: json['scoreCot'],
        scorePh: json['scorePh'],
        scoreAi: json['scoreAi'],
        scoreRsp: json['scoreRsp'],
        scoreCbm: json['scoreCbm'],
        scoreCpf: json['scoreCpf'],
        scoreApf: json['scoreApf'],
        scoreMpr: json['scoreMpr'],
        scoreRf: json['scoreRf'],
        scoreRsimilis: json['scoreRsimilis'],
        index: json['index']
    );
  }

  Map<String, dynamic> toJson() => {
    "year": year,
    "month": month,
    "cot": cot,
    "ph": ph,
    "ai": ai,
    "rsp": rsp,
    "cbm": cbm,
    "cpf": cpf,
    "apf": apf,
    "mpr": mpr,
    "rf": rf,
    "rsimilis": rsimilis,
    "scoreCot": scoreCot,
    "scorePh": scorePh,
    "scoreAi": scoreAi,
    "scoreRsp": scoreRsp,
    "scoreCbm": scoreCbm,
    "scoreCpf": scoreCpf,
    "scoreApf": scoreApf,
    "scoreMpr": scoreMpr,
    "scoreRf": scoreRf,
    "scoreRsimilis": scoreRsimilis,
    "index": index,
  };
}

class DataStorage {
  Future<String> get _cachePath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _cacheFile async {
    final path = await _cachePath;
    return File('$path/locations.txt');
  }

  Future<List<Location>> readLocationsFromCache() async {
    try {
      final file = await _cacheFile;

      final locationsJsonString = await file.readAsString();

      var locationsJsonDynamic = jsonDecode(locationsJsonString);

      Locations locations = Locations.fromJson(locationsJsonDynamic);
      return locations.list;
    } catch (e) {
      // If encountering an error, return empty
      return List<Location>.empty(growable: true);
    }
  }

  Future<List<Location>> readLocationsFromFile(File file) async {
    try {
      final locationsJsonString = await file.readAsString();

      var locationsJsonDynamic = jsonDecode(locationsJsonString);

      Locations locations = Locations.fromJson(locationsJsonDynamic);
      return locations.list;
    } catch (e) {
      // If encountering an error, return empty
      return List<Location>.empty(growable: true);
    }
  }

  Future<File> writeLocationsToCache(List<Location> locations) async {
    final file = await _cacheFile;

    return file.writeAsString(jsonEncode(locations));
  }
}
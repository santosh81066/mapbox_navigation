import 'package:flutter_mapbox_navigation/library.dart';
import 'package:flutter/material.dart';

class SecondNavigation extends StatefulWidget {
  const SecondNavigation({Key? key}) : super(key: key);

  @override
  State<SecondNavigation> createState() => _SecondNavigationState();
}

class _SecondNavigationState extends State<SecondNavigation> {
  MapBoxNavigationViewController? _controller;
  late MapBoxNavigation _directions;
  String _instruction = "";
  bool _isMultipleStop = false;
  double? _distanceRemaining, _durationRemaining;

  bool _routeBuilt = false;
  bool _isNavigating = false;
  final MapBoxOptions _options = MapBoxOptions(
      //initialLatitude: 36.1175275,
      //initialLongitude: -115.1839524,
      zoom: 15.0,
      tilt: 0.0,
      bearing: 0.0,
      enableRefresh: false,
      alternatives: true,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
      allowsUTurnAtWayPoints: true,
      mode: MapBoxNavigationMode.drivingWithTraffic,
      units: VoiceUnits.imperial,
      simulateRoute: false,
      animateBuildRoute: true,
      longPressDestinationEnabled: true,
      language: "en");
  var wayPoints = <WayPoint>[];
  final cityhall =
      WayPoint(name: "City Hall", latitude: 42.886448, longitude: -78.878372);
  final downtown = WayPoint(
      name: "Downtown Buffalo", latitude: 42.8866177, longitude: -78.8814924);
  final _origin =
      WayPoint(name: "Way Point 1", latitude: 17.402573, longitude: 78.520317);
  final _stop1 =
      WayPoint(name: "Way Point 2", latitude: 17.402573, longitude: 78.528485);
  final _stop2 = WayPoint(
      name: "Way Point 3",
      latitude: 38.91040213277608,
      longitude: -77.03848242759705);
  final _stop3 = WayPoint(
      name: "Way Point 4",
      latitude: 38.909650771013034,
      longitude: -77.03850388526917);
  final _stop4 = WayPoint(
      name: "Way Point 5",
      latitude: 38.90894949285854,
      longitude: -77.03651905059814);
  @override
  void initState() {
    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text("Build Route"),
                      onPressed: () {
                        print('from build button');
                        var wayPoints = <WayPoint>[];
                        wayPoints.add(_origin);
                        wayPoints.add(_stop2);
                        wayPoints.add(_stop1);

                        _controller!.buildRoute(wayPoints: wayPoints);
                        print(_controller!.buildRoute(wayPoints: wayPoints));
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        child: Text("Start "),
                        onPressed: () {
                          _controller!.startNavigation();
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      child: Text("Cancel "),
                      onPressed: _isNavigating
                          ? () {
                              _controller!.finishNavigation();
                            }
                          : null,
                    )
                  ],
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Long-Press Embedded Map to Set Destination",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: (Text(
                      _instruction == null || _instruction.isEmpty
                          ? "Banner Instruction Here"
                          : _instruction,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20, top: 20, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[],
                  ),
                ),
                Divider()
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey,
            child: MapBoxNavigationView(
                options: _options,
                onRouteEvent: _onRouteEvent,
                onCreated: (MapBoxNavigationViewController controller) async {
                  _controller = controller;
                  controller.initialize();
                }),
          ),
        )
      ]),
    );
  }

  Future<void> _onRouteEvent(e) async {
    if (_distanceRemaining != null && _durationRemaining != null) {
      _distanceRemaining = await _directions.distanceRemaining;
      _durationRemaining = await _directions.durationRemaining;
    }

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction!;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller!.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }
}

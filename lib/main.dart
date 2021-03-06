import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sound_trek/models/priority_queue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:sound_trek/screens/event_view.dart';
import 'package:sound_trek/screens/playlist_view.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sound_trek/models/user.dart';
import 'package:sound_trek/models/playlist.dart';
import 'package:just_audio/just_audio.dart';
import 'models/events/default_event.dart';
import 'models/events/event.dart';
import 'models/soundtrack_item.dart';
import 'package:flutter/services.dart' show rootBundle;

GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PriorityQueue>(create: (_) => PriorityQueue()),
      ChangeNotifierProvider<User>(create: (_) => User()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SoundTrek',
      theme: ThemeData.dark(),
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _controller;
  Location _location = Location();
  bool _isServiceEnabled = false;
  late PermissionStatus _permissionStatus;
  late LocationData _locationData;
  bool _isListenLocation = false, _isGetLocation = false;
  static const CameraPosition _ourClass = CameraPosition(
    target: LatLng(30.40766724145041, -91.17953531915799),
    zoom: 14.4746,
  );
  late String _aubergineMapStyle;
  Set<Circle> eventCircles = {};

  bool playMusicToggle = false;
  String _title = '';
  String _currentSongTitle = '';
  late Playlist _currentSong;

  Timer? timer;
  final Duration checkEventsInterval = Duration(seconds: 5);

  double appbarSize = 60.0;
  double bottomAppBar = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPerms();
  }

  @override
  Widget build(BuildContext context) {
    final eventsPriorityQueue = Provider.of<PriorityQueue>(context);
    final user = Provider.of<User>(context);
    checkForCurrentEvent(context);

    return Scaffold(
      backgroundColor: Colors.black38,
      key: _drawerKey,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appbarSize),
          child: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(_title,
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                  ]),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _drawerKey.currentState?.openDrawer(),
              ),
              actions: <Widget>[
                SizedBox(
                  height: 60,
                  width: 60,
                  child: IconButton(
                    onPressed: () {setState(() {
                      user.weatherClearToggle = !user.weatherClearToggle;
                    });
                    },
                    icon: user.weatherClearToggle
                        ? SvgPicture.asset('assets/weather_icons/clear.svg', color: Colors.white,)
                        : SvgPicture.asset('assets/weather_icons/rain.svg', color: Colors.white,),
                  ),
                ),
              ],
              bottom: PreferredSize(
                  preferredSize: Size(bottomAppBar, bottomAppBar),
                  child: Container(
                      height: bottomAppBar,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(_currentSongTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ])))
          )),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    0.6,
                    1.0,
                  ],
                  colors: [Colors.black87, Colors.black87])),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('${user.image}'),
                  backgroundColor: Colors.black54,
                ),
                accountEmail: Text('${user.email}',
                  style: TextStyle(color: Colors.white,),
                ),
                accountName: Text(
                  '${user.name}',
                  style: TextStyle(fontSize: 24.0, color: Colors.white,),
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('Events',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EventsPage();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.library_music),
                title: const Text('Playlists',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PlaylistsPage();
                  }));
                },
              ),
              const ListTile(
                leading: Icon(Icons.account_circle_rounded),
                title: Text('Account',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ],
          ),
        ),
      ),
      body: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black87,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _ourClass,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            circles: getCircles(user),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 65,
        child: BottomAppBar(
          color: Colors.transparent,
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.loop_rounded,
                    color: Colors.white,
                      size: 45,
                  ),
                  onPressed: () {
                    user.repeatMusicAll();
                    //TODO: Make condition to alternate all LoopModes (refer to musicplayer_buttons.dart if it helps) ive made a change
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                  onPressed: () {
                    user.previousMusic();
                  },
                ),
                IconButton(
                    icon: playMusicToggle
                        ? const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 45,
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 45,
                          ),
                    onPressed: () {
                      setState(() {
                        playMusicToggle = !playMusicToggle;
                        if (playMusicToggle) {
                          _title = 'Currently playing...';
                          setState(() {
                            appbarSize = 100.0;
                            bottomAppBar = 30;
                            user.playMusic();
                            _currentSongTitle = Playlist.findAssociatedEvent(_currentSong, eventsPriorityQueue) + ' - ' + _currentSong.title;
                          });
                        } else {
                          user.pauseMusic();
                          _title = 'Music paused';
                          _currentSongTitle = '--';
                        }
                      });
                    }),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                  onPressed: () {
                    user.nextMusic();
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.shuffle_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                  onPressed: () {
                    user.shuffleMusic();
                  }
                )
              ]),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(l.latitude as double, l.longitude as double),
              zoom: 15),
        ),
      );
    });
    _loadMapStyles();
  }


  Future<void> _requestLocationPerms() async {
    _isServiceEnabled = await _location.serviceEnabled();

    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();
      if (_isServiceEnabled) return;
    }

    _permissionStatus = await _location.requestPermission();

    if (_permissionStatus == PermissionStatus.denied) {
      _isServiceEnabled = await _location.requestService();
      if (_isServiceEnabled != PermissionStatus.granted) return;
    }

    setState(() {
      _isGetLocation = true;
    });

    print('request has run');
  }

  Future<void> checkForCurrentEvent(BuildContext context) async {
    final eventsPriorityQueue = Provider.of<PriorityQueue>(context);
    final user = Provider.of<User>(context);
    print('check has run');

    if(timer==null) {
        timer = Timer.periodic(checkEventsInterval, (Timer t) => receivingCurrentPlaylist(eventsPriorityQueue, user));

        DefaultEvent defaultev = DefaultEvent();
        defaultev.setInitialized(true);

        List<Event> Startevent = [defaultev];
        eventsPriorityQueue.possibilities.insert(0, SoundtrackItem(Playlist(ConcatenatingAudioSource(children: [
          AudioSource.uri(Uri.parse('asset:///assets/musicsample/town.mp3')),
          AudioSource.uri(Uri.parse('asset:///assets/musicsample/kleinstadt.mp3')),
          AudioSource.uri(Uri.parse('asset:///assets/musicsample/sadge.mp3')),
          AudioSource.uri(Uri.parse('asset:///assets/musicsample/life.mp3')),
          AudioSource.uri(Uri.parse('asset:///assets/musicsample/irish.mp3')),
        ]),
            'Playlist Default', 'default.png'), Startevent));
        _currentSong = eventsPriorityQueue.possibilities.elementAt(1).getPlaylist();
        eventsPriorityQueue.possibilities.removeAt(1);
    }

    _locationData = await _location.getLocation();
    _location.onLocationChanged.listen((loc) {
      user.setCurrentLocation(LatLng(loc.latitude as double, loc.longitude as double));
      print(user.getCurrentLocation().latitude.toString() + " " + user.getCurrentLocation().longitude.toString());
    });
  }

  Future<void> receivingCurrentPlaylist(PriorityQueue queueIn, User user) async {
    SoundtrackItem item = queueIn.Update(user);

    if(item.getEventList().elementAt(0).getInitialized()){
      print("Trying Update");
      if(!identical(_currentSong, item.getPlaylist())) {
        setState(() {
          _currentSong = item.getPlaylist();
          _currentSong.passToMusicPlayer(user);
          if(_title != '') {
            _currentSongTitle = Playlist.findAssociatedEvent(_currentSong, queueIn) + ' - ' + _currentSong.title;
          }
        });
      }else{
        print("same song");
      }
    }else{
      print("beartrap");
    }

  }

  Future<void> _loadMapStyles() async {
    _aubergineMapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_styles/aubergine.json');
    _controller.setMapStyle(_aubergineMapStyle);
  }

  Set<Circle> getCircles(User user) {
    setState(() {
      eventCircles = user.getCircles();
    });
    print(eventCircles.toString());
    return eventCircles;
  }

}


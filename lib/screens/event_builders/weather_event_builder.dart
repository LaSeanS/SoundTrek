import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_trek/models/soundtrack_item.dart';
import 'package:sound_trek/screens/add_playlists.dart';
import 'package:sound_trek/models/events/weather_event.dart';
import 'package:sound_trek/models/events/weather_handler.dart';
import 'package:sound_trek/models/priority_queue.dart';
import 'package:sound_trek/models/playlist.dart';
import 'package:sound_trek/models/events/event.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sound_trek/models/user.dart';

class BuildWeatherEvent extends StatefulWidget {
  const BuildWeatherEvent({Key? key}) : super(key: key);

  @override
  BuildWeatherEventState createState() {
    return BuildWeatherEventState();
  }
}

class BuildWeatherEventState extends State<BuildWeatherEvent> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  WeatherCondition weatherCondition = WeatherCondition.clear;
  late Playlist playlist;
  String weatherIcon = 'assets/weather_icons/clear.svg';

  @override
  Widget build(BuildContext context) {
    final eventsPriorityQueue = Provider.of<PriorityQueue>(context);
    final user = Provider.of<User>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Choose a Weather Condition"),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 200,
                  width: 200,
                  child: SvgPicture.asset(
                    weatherIcon,
                    color: Colors.white,
                    //colorBlendMode: BlendMode.multiply,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
                  child: DropdownButton<WeatherCondition>(
                    value: weatherCondition,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 20,
                    elevation: 1,
                    style: const TextStyle(color: Colors.white),
                    alignment: Alignment.center,
                    focusColor: Colors.grey,
                    underline: Container(
                      height: 2,
                      color: const Color.fromARGB(255, 149, 215, 201),
                    ),
                    onChanged: (WeatherCondition? selectedCond) {
                      setState(() {
                        weatherCondition = selectedCond!;
                        weatherIcon = 'assets/weather_icons/' +
                            weatherCondition.toString().split('.').last +
                            '.svg';
                      });
                    },
                    items: <WeatherCondition>[
                      WeatherCondition.thunderstorm,
                      WeatherCondition.drizzle,
                      WeatherCondition.rain,
                      WeatherCondition.snow,
                      WeatherCondition.fog,
                      WeatherCondition.lightCloud,
                      WeatherCondition.heavyCloud,
                      WeatherCondition.clear,
                      WeatherCondition.unknown
                    ].map<DropdownMenuItem<WeatherCondition>>(
                        (WeatherCondition option) {
                      return DropdownMenuItem<WeatherCondition>(
                        value: option,
                        child: Text(
                          displayWeather(option),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(color: const Color.fromARGB(255, 149, 215, 201)),
                            ),
                          ),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.fromLTRB(15, 10, 12, 10)),
                          backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 149, 215, 201)),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed: () {
                          addPlaylists(context);
                        },
                        child: Text('+  Playlists',
                            style: TextStyle(
                                fontSize: 20
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0, 0, 0, 0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(color: const Color.fromARGB(255, 149, 215, 201)),
                              ),
                            ),
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.fromLTRB(15, 10, 12, 10)),
                            backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 149, 215, 201)),
                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          onPressed: () {
                            createWeatherEvent(eventsPriorityQueue, user);
                            Navigator.pop(context);
                          },
                          child: Text('Create Event',
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addPlaylists(BuildContext context) async {
    final Playlist chosenPlaylist =
        await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPlaylists()),
        );

    setState(() {
      playlist = chosenPlaylist;
    });
  }

  void createWeatherEvent(PriorityQueue events, user) {
    String eventListName =
        'Event ' + (events.possibilities.length).toString();
    List<Event> eventList = [WeatherEvent(displayWeather(weatherCondition), eventListName)];

    SoundtrackItem item = SoundtrackItem(playlist, eventList);
    events.addItem(item);
  }

  String displayWeather(WeatherCondition weather) {
    String weatherText = weather.toString().split('.').last;

    switch (weatherText) {
      case 'thunderstorm':
        weatherText = 'Thunderstorm';
        break;
      case 'drizzle':
        weatherText = 'Drizzle';
        break;
      case 'rain':
        weatherText = 'Rain';
        break;
      case 'snow':
        weatherText = 'Snow';
        break;
      case 'clear':
        weatherText = 'Clear';
        break;
      case 'heavyCloud':
        weatherText = 'Heavy Clouds';
        break;
      case 'lightCloud':
        weatherText = 'Light Clouds';
        break;
      case 'fog':
        weatherText = 'Fog';
        break;
      default:
        weatherText = 'Unknown';
    }

    return weatherText;
  }
}

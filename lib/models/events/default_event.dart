import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sound_trek/models/events/event.dart';
import 'package:sound_trek/models/user.dart';

class DefaultEvent implements Event {


  bool _initialized = false;
  String _name = "Default Event";

  DefaultEvent();

  @override
  bool isHappening(User user) {
    return true;
  }

  @override
  String getType(){
    return "Default";
  }

  @override
  String toString(){
    return "Wilderness "+_initialized.toString();
  }

  @override
  bool getInitialized() {
    return _initialized;
  }

  @override
  void setInitialized(initializedIn) {
    _initialized = initializedIn;
  }

  @override
  String getName(){
    return _name;
  }

  CircleId getCircleId() {
    return CircleId('none');
  }

}
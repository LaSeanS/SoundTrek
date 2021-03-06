import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:sound_trek/models/user.dart';
import 'package:sound_trek/models/playlist.dart';
import 'package:sound_trek/models/priority_queue.dart';

class AddPlaylists extends StatefulWidget {
  const AddPlaylists({Key? key}) : super(key: key);

  @override
  AddPlaylistsState createState() {
    return AddPlaylistsState();
  }
}

class AddPlaylistsState extends State<AddPlaylists> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<Playlist> playlistList = [];
  List<bool> selected = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final eventsPriorityQueue = Provider.of<PriorityQueue>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // automaticallyImplyLeading: true,
        title: Text('Playlists'),
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: Colors.black38,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.4,
                  1.0,
                ],
                colors: [Colors.black54, Color.fromARGB(255, 149, 215, 201)])),
        child: ListView.builder(
          itemCount: user.usersPlaylists.length,
          itemBuilder: (context, index) {
            final playlist = user.usersPlaylists[index];

            return buildListTile(playlist, selected, playlistList, index);
          },
        ),
      ),
      floatingActionButton: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(color: Colors.white),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.fromLTRB(15, 10, 12, 10)),
          backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 149, 215, 201)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: () {
          Navigator.pop(context, playlistList.elementAt(0));
        },
        child: Text('Done',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget buildListTile(Playlist playlist, List<bool> selected,
      List<Playlist> playlistList, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.white.withOpacity(0.15),
      child: Container(
        foregroundDecoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/album_covers/${playlist.coverName}'),
            fit: BoxFit.fitHeight,
            alignment: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.fromLTRB(105, 20, 20, 20),
          title: Text(
            '${playlist.title}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          value: selected.elementAt(index),
          activeTrackColor: const Color.fromARGB(255, 149, 215, 201),
          activeColor: Colors.teal,
          onChanged: (bool value) {
            setState(() {
              if (value) {
                playlistList.add(playlist);
              } else {
                playlistList.remove(playlist);
              }
              selected[index] = value;
            });
          },
          dense: false,
        ),
      ),
    );
  }
}

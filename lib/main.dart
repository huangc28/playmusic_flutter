import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/music_stream_bloc.dart';
import './bloc/search_yt_url_bloc.dart';

import './landing.dart';
import './service_locator.dart';

void main() async {
  await setupServiceLocator();

  runApp(PlayMusic());
}

class PlayMusic extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MusicStreamBloc(),
        ),
        BlocProvider(
          create: (_) => SearchYtUrlBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'playmusic',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) => Landing(),
        ),
      ),
    );
  }
}

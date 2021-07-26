import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'service_locator.dart';
import 'page_manager.dart';

class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve page manager, listen to page playlist notifier
    final pageManager = getIt<PageManager>();

    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${playlistTitles[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}

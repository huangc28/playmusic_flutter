import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:playmusic_flutter/constants/loading_status.dart';
import 'package:playmusic_flutter/exceptions.dart';

part './search_yt_url_event.dart';
part './search_yt_url_state.dart';

class SearchYtUrlResponse {
  const SearchYtUrlResponse({
    this.ytStreamUrl,
  });

  final String? ytStreamUrl;

  factory SearchYtUrlResponse.fromMap(Map<String, dynamic> map) {
    return SearchYtUrlResponse();
  }
}

class SearchYtUrlBloc extends Bloc<SearchYtUrlEvent, SearchYtUrlState> {
  SearchYtUrlBloc() : super(SearchYtUrlInitial());

  @override
  Stream<SearchYtUrlState> mapEventToState(
    SearchYtUrlEvent event,
  ) async* {
    if (event is SearchYtUrl) {
      yield* _mapSearchYtUrlToState(event);
    }
  }

  Stream<SearchYtUrlState> _mapSearchYtUrlToState(SearchYtUrl event) async* {
    try {
      yield SearchingYtUrl();

      final uri = Uri(
        scheme: 'http',
        host: '10.0.2.2',
        port: 8080,
        path: 'audio-source',
        queryParameters: {
          'vurl': event.url,
        },
      );

      final request = http.Request(
        'GET',
        uri,
      );

      final streamResp = await http.Client().send(request);

      final res = await http.Response.fromStream(streamResp);

      if (res.statusCode != HttpStatus.ok) {
        print('DEBUG 1 _mapSearchYtUrlToState ${json.decode(res.body)}');
        throw ApiException.fromJson(json.decode(res.body));
      }

      final resMap = json.decode(res.body);

      print('DEBUG url ${resMap['stream_url']}');

      yield SearchYtUrlDone(resMap['stream_url']);
    } on ApiException catch (err) {
      yield SearchYtUrlError(err);
    } on Exception catch (err) {
      print('DEBUG unknown exception $err');
    }
  }
}

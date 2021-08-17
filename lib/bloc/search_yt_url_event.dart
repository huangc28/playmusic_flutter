part of 'search_yt_url_bloc.dart';

abstract class SearchYtUrlEvent extends Equatable {
  const SearchYtUrlEvent();

  @override
  List<Object> get props => [];
}

class SearchYtUrl extends SearchYtUrlEvent {
  final String url;

  SearchYtUrl({
    required this.url,
  });
}

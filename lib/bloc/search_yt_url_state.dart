part of 'search_yt_url_bloc.dart';

abstract class SearchYtUrlState extends Equatable {
  const SearchYtUrlState({
    this.loading = LoadingStatus.initial,
    this.streamUrl,
    this.e,
  });

  final LoadingStatus loading;

  final String? streamUrl;

  final ApiException? e;

  @override
  List<Object?> get props => [
        loading,
        streamUrl,
        e,
      ];
}

class SearchYtUrlInitial extends SearchYtUrlState {
  const SearchYtUrlInitial() : super(loading: LoadingStatus.initial);
}

class SearchingYtUrl extends SearchYtUrlState {
  const SearchingYtUrl() : super(loading: LoadingStatus.loading);
}

class SearchYtUrlDone extends SearchYtUrlState {
  const SearchYtUrlDone(String ytStreamUrl)
      : super(
          streamUrl: ytStreamUrl,
          loading: LoadingStatus.done,
        );
}

class SearchYtUrlError extends SearchYtUrlState {
  const SearchYtUrlError(
    ApiException e,
  ) : super(
          e: e,
          loading: LoadingStatus.error,
        );
}

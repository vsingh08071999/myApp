import 'package:newapplication/bloc/AuthBloc.dart';
import 'package:newapplication/bloc/connectivityBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainBloc {
  static List<BlocProvider> allBlocs() {
    return [
      BlocProvider<ConnectivityBloc>(
        create: (_) => ConnectivityBloc(),
      ),
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(),
      ),
    ];
  }
}

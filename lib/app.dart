import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'injection_container.dart' as di;

/// Root widget for the Plately application.
///
/// Wraps everything in [MultiBlocProvider] so that top-level cubits
/// (e.g. [ThemeCubit]) are available throughout the widget tree.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<ThemeCubit>(create: (_) => di.sl<ThemeCubit>())],
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Plately',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeCubit.toFlutterThemeMode(themeMode),
            routerConfig: di.sl<GoRouter>(),
          );
        },
      ),
    );
  }
}

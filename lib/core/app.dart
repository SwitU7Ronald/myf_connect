import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/routes/app_router.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/services/auth/auth_bloc.dart';

class MYFConnectApp extends StatelessWidget {
  const MYFConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'MYF Connect',
        theme: MyfTheme.lightTheme,
        darkTheme: MyfTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

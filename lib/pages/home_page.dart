import 'package:flutter/material.dart';
import 'package:flutter_weather_cubit/cubits/weather/weather_cubit.dart';
import 'package:flutter_weather_cubit/pages/search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_cubit/widgets/error_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              _city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SearchPage();
                  },
                ),
              );
              print('city: $_city');
              if (_city != null) {
                context.read<WeatherCubit>().fetchWeather(_city!);
              }
            },
          ),
        ],
      ),
      body: _showWeather(),
    );
  }

  Widget _showWeather() {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listener: (context, state) {
        if (state.status == WeatherStatus.error) {
          errorDialog(context, state.error.errMsg);
        }
      },
      builder: (context, state) {
        if (state.status == WeatherStatus.initial) {
          return Center(
            child: Text(
              'Select a city',
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }
        if (state.status == WeatherStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == WeatherStatus.error && state.weather.title == '') {
          return Center(
            child: Text(
              'Select a city',
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }

        return ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
            ),
            Text(
              state.weather.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              TimeOfDay.fromDateTime(state.weather.lastUpdated).format(context),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${state.weather.maxTemp}',
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  '${state.weather.minTemp}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

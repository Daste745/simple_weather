import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../util/utils.dart' as utils;

class SimpleWeather extends StatefulWidget {
  SimpleWeather({Key key}) : super(key: key);

  @override
  _SimpleWeatherState createState() => _SimpleWeatherState();
}

class _SimpleWeatherState extends State<SimpleWeather> {
  String _cityName;

  Future _pushSearchScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute<Map<dynamic, dynamic>>(
        builder: (BuildContext context) {
          return Search();
        },
      ),
    );

    if (results != null && results.containsKey('cityName')) {
      print(results['cityName']);
      _cityName = results['cityName'];
      // _updateCityName(results['cityName']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          backgroundWidget(_cityName),
          cityWidget(_cityName),
          tempWidget(_cityName),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Search',
        backgroundColor: Colors.black,
        onPressed: () => _pushSearchScreen(context),
        child: Icon(
          Icons.search,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget cityWidget(String cityName) {
    return FutureBuilder(
      future: getWeather(cityName == null ? utils.defaultCity : cityName),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.fromLTRB(0, 40, 30, 0),
            child: Text(
              snapshot.data['name'],
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget backgroundWidget(String cityName) {
    return FutureBuilder(
      future: getWeather(cityName == null ? utils.defaultCity : cityName),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          var image;
          // snapshot.data['weather'][0]['main']
          switch (snapshot.data['weather'][0]['main']) {
            case 'Clouds':
              image = AssetImage('images/clouds.jpg');
              break;
            case 'Mist':
            case 'Fog':
              image = AssetImage('images/fog.jpg');
              break;
            case 'Snow':
              image = AssetImage('images/snow.jpg');
              break;
            case 'Rain':
              image = AssetImage('images/rain.jpg');
              break;
            case 'Sun':
              image = AssetImage('images/sun.jpg');
              break;
            case 'Clear':
            default:
              image = AssetImage('images/clear.jpg');
              break;
          }

          return Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.15, 0.5, 0.65, 1],
                    colors: <Color>[
                      Colors.white38,
                      Colors.white10,
                      Colors.black.withOpacity(0),
                      Colors.black26,
                      Colors.black87,
                    ],
                  ),
                ),
              )
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget tempWidget(String cityName) {
    return FutureBuilder(
      future: getWeather(cityName == null ? utils.defaultCity : cityName),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            alignment: Alignment.bottomLeft,
            margin: EdgeInsets.fromLTRB(30, 0, 0, 50),
            child: ListTile(
              title: Text(
                '${snapshot.data['main']['temp'].round()}°C',
                style: TextStyle(
                  fontSize: 65,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Feels like ${snapshot.data['main']['feels_like'].round()}°C\n'
                'Min ${snapshot.data['main']['temp_min'].round()}°C\n'
                'Max ${snapshot.data['main']['temp_max'].round()}°C\n'
                '${snapshot.data['weather'][0]['main']}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Future<Map> getWeather(String cityName) async {
    cityName.replaceAll(' ', '+');
    final String appId = utils.appId;
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$appId&units=metric';
    final Response response = await get(apiUrl);

    return jsonDecode(response.body);
  }
}

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var _searchTextFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Search',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: TextField(
                controller: _searchTextFieldController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'City Name',
                  isDense: true,
                ),
                style: TextStyle(
                  fontSize: 30,
                ),
                onSubmitted: (String text) => print('Input name: $text'),
              ),
            ),
            FlatButton(
              child: Text(
                'Search',
              ),
              onPressed: () => Navigator.pop(
                context,
                {
                  'cityName': _searchTextFieldController.text,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

String body = '';

abstract class ABI {
  Future<Response> getusers();
}

class JsonPlaceholder implements ABI {
  final String _host = "https://jsonplaceholder.typicode.com/Users/1";
  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
  };
  @override
  Future<Response> getusers() async {
    return await get(Uri.parse(_host), headers: headers);
  }
}

//web socket
class Company {
  String name;
  String catchPhrase;
  String bs;
  Company({required this.name, required this.bs, required this.catchPhrase});
  factory Company.fromjason(Map<String, String> jason) {
    return Company(
        name: jason['name'] as String,
        bs: jason['bs'] as String,
        catchPhrase: jason['catchPhrase'] as String);
  }
}

class Geo {
  String lat;
  String lng;
  Geo({required this.lat, required this.lng});
  factory Geo.fromjson(Map<String, String> json) {
    return Geo(lat: json['lat'] as String, lng: json['lng'] as String);
  }
}

class Address {
  String street;
  String suite;
  String city;
  String zipcode;
  Geo geo;
  Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromjson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      suite: json['suite'] as String,
      city: json['city'] as String,
      zipcode: json['zipcode'] as String,
      geo: Geo.fromjson(jsonDecode(json['geo'])),
    );
  }
}

class Users {
  int id;
  String name;
  String username;
  String email;
  Address address;
  String phone;
  String website;
  Company company;

  Users({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.address,
    required this.phone,
    required this.website,
    required this.company,
  });
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      address: Address.fromjson(json['address']),
      phone: json['phone'] as String,
      website: json['website'] as String,
      company: Company.fromjason(jsonDecode(json['company'])),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<Users> getuser() async {
  JsonPlaceholder jsonPlaceholder = JsonPlaceholder();
  Response response = await jsonPlaceholder.getusers();
  if (response.statusCode == 200) {
    body = response.body;

    Map<String, dynamic> map = jsonDecode(body);
    return Users.fromJson(map);
  }
  throw Exception;
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Users>? _users;
  @override
  initState() {
    _users = getuser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder(
              future: _users,
              builder: (context, AsyncSnapshot<Users> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasData) {
                      Users myuser = snapshot.data!;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(myuser.name),
                          ),
                          Expanded(child: Text(myuser.email)),
                          Expanded(child: Text(myuser.website)),
                        ],
                      );
                    } else {
                      return Text(snapshot.error.toString());
                    }
                }
              })),
    );
  }
}

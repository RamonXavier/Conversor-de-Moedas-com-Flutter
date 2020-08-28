import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:convert/convert.dart';
import 'dart:async';
import 'dart:convert';

const UrlApi = "https://api.hgbrasil.com/finance?format=json-cors&key=95e3f75d";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.white,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.green[800], width: 3))))));
}

Future<Map> getData() async {
  http.Response response = await http.get(UrlApi);
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realAlter(String valor) {
    double real = double.parse(valor);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarAlter(String valor) {
    double dolar = double.parse(valor);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroAlter(String valor) {
    double euro = double.parse(valor);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _zeraValores() {
    setState(() {
      dolarController.text = "";
      euroController.text = "";
      realController.text = "";
    });
  }

  double dolar;
  double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            "Conversor de Moedas",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          backgroundColor: Colors.green[900],
          centerTitle: true,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Carregando Dados...",
                        style: TextStyle(color: Colors.white, fontSize: 34),
                        textAlign: TextAlign.center),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Erro durante processamento... :(",
                          style: TextStyle(color: Colors.white, fontSize: 34),
                          textAlign: TextAlign.center),
                    );
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Zerar Valores",
                                style: TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.refresh),
                                tooltip: 'Zerar Valores',
                                onPressed: () => _zeraValores(),
                                color: Colors.white,
                                iconSize: 48,
                              ),
                              Icon(
                                Icons.monetization_on,
                                size: 170,
                                color: Colors.green[800],
                              ),
                            ],
                          ),
                          constroiTextField(
                              "Reais", "R", realController, _realAlter),
                          Divider(),
                          constroiTextField(
                              "Dólar", "US", dolarController, _dolarAlter),
                          Divider(),
                          constroiTextField(
                              "Euro", "€", euroController, _euroAlter),
                          Divider(
                            height: 65.0,
                          ),
                          Text(
                            'Para converter, basta digitar o valor da moeda desejada ' +
                                'no campo referente.',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 19),
                          ),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget constroiTextField(String label, String prefix,
    TextEditingController controlador, Function funcao) {
  return TextField(
    controller: controlador,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green[600], fontSize: 20),
      border: OutlineInputBorder(),
      prefixText: prefix + "\$",
    ),
    style: TextStyle(color: Colors.white, fontSize: 30),
    onChanged: funcao,
    keyboardType: TextInputType.number,
  );
}

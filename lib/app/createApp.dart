import 'package:flutter/material.dart';
import 'package:listadetarefas/app/home/myHomePage.dart';

class CreateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista de Tarefas",
      home: MyHomePage(),
    );
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(CreateApp());
}

class CreateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista de tarefas",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _indexLastRemoved;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDoList() {
    String text = _toDoController.text.trim();
    if(text.isNotEmpty){
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = text;
      newToDo["finished"] = false;
      setState(() {
        _toDoList.insert(0, newToDo);
        _toDoController.clear();
      });
      _saveData();
    }
  }

  void _changeState(bool finished, int index) {
    setState(() {
      _toDoList[index]["finished"] = finished;
    });
    _saveData();
  }

  Future<Null> _refreshToDoList() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((element1, element2) {
        if (element1["finished"] == true) {
          return 1;
        } else {
          return -1;
        }
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    onEditingComplete: _addToDoList,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDoList,
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _refreshToDoList,
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: _buildItem),
          ))
        ],
      ),
    );
  }

  Widget _buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            )),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["finished"],
          secondary: CircleAvatar(
              child: Icon(
                  _toDoList[index]["finished"] ? Icons.check : Icons.error)),
          onChanged: (finished) => _changeState(finished, index)),
      onDismissed: (direction) {
        _lastRemoved = Map.from(_toDoList[index]);
        _indexLastRemoved = index;
        setState(() {
          _toDoList.removeAt(index);
          _saveData();
          final snackBar = SnackBar(
            content: Text("Tarefa Removida! '${_lastRemoved["title"]}'."),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_indexLastRemoved, _lastRemoved);
                  _saveData();
                });
              },
              textColor: Colors.red,
            ),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

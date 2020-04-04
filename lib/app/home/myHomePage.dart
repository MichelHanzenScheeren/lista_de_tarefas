import 'dart:async';
import 'package:flutter/material.dart';
import 'package:listadetarefas/app/data/myData.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _toDoController = TextEditingController();
  MyData data = MyData();
  Map<String, dynamic> _lastRemoved;
  int _indexLastRemoved;

  @override
  void initState(){
    super.initState();
    setState(() {
      data.readData();
    });
  }

  void _addToDoList() {
    String text = _toDoController.text.trim();
    if(text.isNotEmpty){
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = text;
      newToDo["finished"] = false;
      setState(() {
        data.addData(0, newToDo);
        _toDoController.clear();
      });
    }
  }

  void _changeState(bool finished, int index) {
    setState(() {
      data.changeState(finished, index);
    });
  }

  Future<Null> _refreshToDoList() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      data.sortData();
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
                    itemCount: data.length(),
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
          title: Text(data.getTitle(index)),
          value: data.getFinished(index),
          secondary: CircleAvatar(
              child: Icon(
                  data.getFinished(index) ? Icons.check : Icons.error)),
          onChanged: (finished) => _changeState(finished, index)),
      onDismissed: (direction) {
        _lastRemoved = Map.from(data.getDataIndex(index));
        _indexLastRemoved = index;
        setState(() {
          data.removeAt(index);
          final snackBar = SnackBar(
            content: Text("Tarefa Removida! '${_lastRemoved["title"]}'."),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  data.addData(_indexLastRemoved, _lastRemoved);
                });
              },
              textColor: Colors.red,
            ),
            duration: Duration(seconds: 5),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
  }


}
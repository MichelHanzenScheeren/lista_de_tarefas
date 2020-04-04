import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class MyData {
  List _toDoList = [];

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<Null> addData(int position, Map<String, dynamic> newToDo) async{
    _toDoList.insert(position, newToDo);
    await _saveData();
  }

  Future<Null> changeState(bool finished, int index) async{
    _toDoList[index]["finished"] = finished;
    await _saveData();
  }

  Future<Null> removeAt(int index) async {
    _toDoList.removeAt(index);
    await _saveData();
  }

  Future<Null> sortData() async{
    _toDoList.sort((element1, element2) {
      if (element1["finished"] == true) {
        return 1;
      } else {
        return -1;
      }
    });
    await _saveData();
  }

  int length(){
    return _toDoList.length;
  }

  String getTitle(int index){
    return _toDoList[index]["title"];
  }

  bool getFinished(int index){
    return _toDoList[index]["finished"];
  }

  Map<String, dynamic> getDataIndex(int index) {
    return _toDoList[index];
  }

  Future<Null> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    await file.writeAsString(data);
  }

  Future<Null> readData() async {
    try {
      final file = await _getFile();
      _toDoList =  json.decode(await file.readAsString());
    } catch (e) {
      return null;
    }
  }
}
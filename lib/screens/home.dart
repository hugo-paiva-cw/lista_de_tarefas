import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _taskList = [];
  Map<String, dynamic> _lastTaskRemoved = {};

  final TextEditingController _controllerTask = TextEditingController();

  _saveTask() {
    String _typedText = _controllerTask.text;
    Map<String, dynamic> task = {};
    task['title'] = _typedText;
    task['status'] = false;
    setState(() {
      _taskList.add(task);
    });
    _saveData();
    _controllerTask.text = '';
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/myfile.json');
  }

  _saveData() async {
    var file = await _getFile();

    String data = json.encode(_taskList);
    file.writeAsString(data);
  }

  _readFile() async {
    try {
      var file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    _readFile().then((data) {
      setState(() {
        _taskList = json.decode(data);
      });
    });
    super.initState();
  }

  Widget _createItemFromList(context, index) {
    final item = _taskList[index]['title'];
    return Dismissible(
        onDismissed: (direction) {
          // Recover latest item removed
          _lastTaskRemoved = _taskList[index];

          _taskList.removeAt(index);
          _saveData();

          var snackbar = SnackBar(
            content: const Text('Tarefa removida'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {

                setState(() {
                  _taskList.insert(index, _lastTaskRemoved);
                });
                _saveData();

              },
            ),
            duration: const Duration(seconds: 5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ],
          ),
        ),
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        // This key behaves like an unique id so its better to be like a random number
        child: CheckboxListTile(
            title: Text(_taskList[index]['title']),
            value: _taskList[index]['status'],
            onChanged: (alteredValue) {
              setState(() {
                _taskList[index]['status'] = alteredValue;
              });
              _saveData();
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Lista de tarefas'),
      ),
      body: ListView.builder(
          itemCount: _taskList.length, itemBuilder: _createItemFromList),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Adicionar Tarefa'),
                  content: TextField(
                    keyboardType: TextInputType.text,
                    decoration:
                        const InputDecoration(label: Text('Digite sua tarefa')),
                    controller: _controllerTask,
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar')),
                    FlatButton(
                        onPressed: () {
                          _saveTask();
                          Navigator.pop(context);
                        },
                        child: const Text('Salvar')),
                  ],
                );
              });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/CustomDrawer.dart';
import 'package:to_do_app/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blueAccent),
      home: ToDoScreen(),
    );
  }
}

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await dbHelper.fetchTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask() async {
    _titleController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Task"),
        content: TextField(
          controller: _titleController,
          decoration: InputDecoration(labelText: "Title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                await dbHelper.insertTask(_titleController.text);
                _loadTasks();
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTaskCompletion(int taskId) async {
    final task = _tasks.firstWhere((task) => task['id'] == taskId);
    int newStatus = task['isCompleted'] == 1 ? 0 : 1;

    await dbHelper.updateTask(taskId, task['title'], newStatus);
    _loadTasks();
  }

  Future<void> _editTask(int taskId, String currentTitle) async {
    _titleController.text = currentTitle;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: TextField(
          controller: _titleController,
          decoration: InputDecoration(labelText: "Title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                await dbHelper.updateTask(taskId, _titleController.text, 0);
                _loadTasks();
                Navigator.pop(context);
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int taskId) async {
    await dbHelper.deleteTask(taskId);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "To-Do List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task["title"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Created: ${DateFormat.yMMMd().format(DateTime.parse(task["createdAt"]))}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                task["isCompleted"] == 1
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task["isCompleted"] == 1
                                    ? Colors.teal
                                    : Colors.grey,
                              ),
                              onPressed: () =>
                                  _toggleTaskCompletion(task["id"]),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () =>
                                  _editTask(task["id"], task["title"]),
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteTask(task["id"]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

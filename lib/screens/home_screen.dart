import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';
import '../widgets/task_card.dart';
import '../widgets/login_register_wrapper.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasksFromApi = await ApiService.getTasks();
      setState(() {
        tasks = tasksFromApi;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar tareas: $e')),
      );
    }
  }

  Future<void> _navigateToTaskForm({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (result != null && result is Task) {
      try {
        if (task != null) {
          await ApiService.updateTask(task.id, result);
        } else {
          await ApiService.createTask(result);
        }
        _loadTasks();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la tarea: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await ApiService.deleteTask(task.id);
      _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar tarea: $e')),
      );
    }
  }

  Future<void> _toggleCompletion(Task task) async {
    try {
      await ApiService.toggleTaskCompletion(task.id, !task.completada);
      _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar tarea: $e')),
      );
    }
  }

  void _logout() {
    ApiService.setToken(""); // Limpia el token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginRegisterWrapper()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? const Center(
        child: Text(
          'No hay tareas disponibles',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onEdit: () => _navigateToTaskForm(task: task),
            onDelete: () => _deleteTask(task),
            onToggleComplete: () => _toggleCompletion(task),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTaskForm(),
        tooltip: 'Agregar nueva tarea',
        child: const Icon(Icons.add),
      ),
    );
  }
}

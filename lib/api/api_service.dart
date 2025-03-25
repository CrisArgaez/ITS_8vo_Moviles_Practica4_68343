import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class ApiService {
  static final String _baseUrl = dotenv.get('API_URL');
  static String? _token;

  // ==========================
  // Persistencia del token JWT
  // ==========================

  static const String _tokenKey = 'jwt_token';

  // Guardar el token (en memoria y en SharedPreferences)
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Obtener token desde SharedPreferences (al iniciar la app)
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  // Limpiar token (logout)
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Acceso de solo lectura al token
  static String? get token => _token;

  // Headers comunes
  static Map<String, String> _headers({bool authenticated = false}) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (authenticated && _token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ==========================
  // AUTENTICACIÓN
  // ==========================

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await setToken(data['token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _headers(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    return response.statusCode == 201;
  }

  // ==========================
  // TAREAS
  // ==========================

  static Future<List<Task>> getTasks() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tareas'),
      headers: _headers(authenticated: true),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las tareas');
    }
  }

  static Future<Task> getTaskById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tareas/$id'),
      headers: _headers(authenticated: true),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar la tarea');
    }
  }

  static Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tareas'),
      headers: _headers(authenticated: true),
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear la tarea');
    }
  }

  static Future<Task> updateTask(int id, Task task) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/tareas/$id'),
      headers: _headers(authenticated: true),
      body: json.encode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la tarea');
    }
  }

  static Future<Task> toggleTaskCompletion(int id, bool completed) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/tareas/$id'),
      headers: _headers(authenticated: true),
      body: json.encode({'completada': completed}),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el estado de la tarea');
    }
  }

  static Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/tareas/$id'),
      headers: _headers(authenticated: true),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la tarea');
    }
  }
}

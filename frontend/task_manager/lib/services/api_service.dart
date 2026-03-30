import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/tasks/';

  Future<List<Task>> fetchTasks({String? search, String? status}) async {
    await Future.delayed(const Duration(seconds: 2));
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    final response = await http.put(
      Uri.parse('$baseUrl${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    final response = await http.delete(Uri.parse('$baseUrl$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}

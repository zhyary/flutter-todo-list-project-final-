import 'dart:convert';
import 'package:http/http.dart' as http;
import 'todo.dart';

class TodoRepository {
  final String baseUrl = 'http://localhost:4000/api/items';

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse(baseUrl));

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Todo.fromJson(e)).toList();
    } else {
      throw Exception('Could not fetch todos');
    }
  }

  Future<Todo> addTodo(String text) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'status': 0, 'person_id': 0}),
    );

    if (response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<Todo> toggleTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': todo.status == 1 ? 0 : 1}),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update todo');
    }
  }
}

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'todo.dart';
import 'todoRepository.dart';

final todoListProvider =
    StateNotifierProvider<TodoListNotifier, AsyncValue<List<Todo>>>((ref) {
  return TodoListNotifier();
});

class TodoListNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  TodoListNotifier() : super(const AsyncValue.loading()) {
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      final todos = await TodoRepository().fetchTodos();
      state = AsyncValue.data(todos);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> add(String text) async {
    try {
      final newTodo = await TodoRepository().addTodo(text);
      state = AsyncValue.data([...state.value ?? [], newTodo]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggle(Todo todo) async {
    try {
      final updatedTodo = await TodoRepository().toggleTodo(todo);
      state = AsyncValue.data([
        for (final t in state.value ?? []) t.id == todo.id ? updatedTodo : t
      ]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

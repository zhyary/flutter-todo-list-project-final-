import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'providers.dart';
import 'todo.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulHookConsumerWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  // Method to trigger a manual refresh of the todo list
  Future<void> onRefresh() {
    return ref.read(todoListProvider.notifier).fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    final todosProvider = ref.watch(todoListProvider);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Todo List'),
            actions: [
              // Add refresh button in AppBar
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh, // Refresh when pressed
              ),
            ],
          ),
          body: todosProvider.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const Center(
              child: Text(
                  'Couldn\'t make API request. Make sure server is running.'),
            ),
            data: (todos) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              children: [
                TextField(
                  controller: newTodoController,
                  decoration: const InputDecoration(
                    labelText: 'What do we need to do?',
                  ),
                  onSubmitted: (value) {
                    // Add new todo and trigger refresh
                    ref.read(todoListProvider.notifier).add(value).then((_) {
                      onRefresh(); // Trigger refresh after adding
                    });
                    newTodoController.clear();
                  },
                ),
                const SizedBox(height: 20),
                // List of todos, each clickable to trigger refresh
                for (var todo in todos)
                  TodoItem(
                      todo: todo,
                      onPressed: onRefresh), // Pass onRefresh as parameter
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoItem extends HookConsumerWidget {
  final Todo todo;
  final Future<void> Function()? onPressed;

  const TodoItem({required this.todo, this.onPressed, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: todo.status == 1, // Assume 1 = completed
        onChanged: (value) {
          // Toggle the todo's completion status
          ref.read(todoListProvider.notifier).toggle(todo).then((_) {
            onPressed!(); // Trigger refresh after toggle
          });
        },
      ),
      title: Text(todo.text),
      onTap: () {
        if (onPressed != null) {
          onPressed!(); // Trigger refresh when the todo item is tapped
        }
      },
    );
  }
}

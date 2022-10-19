import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'models.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoリスト',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDoリスト'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isEditing = ref.watch(editProvider.state);
              return IconButton(
                onPressed: ()=>isEditing.state = !isEditing.state,
                icon: isEditing.state?const Icon(Icons.check):const Icon(Icons.edit),
              );
            }
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final List<ToDo> todos = ref.watch(todosProvider);
                final isEditing = ref.watch(editProvider.state);
                return Flexible(
                  child: ReorderableListView(
                    header: isEditing.state?const AddTile(isTop: true):Container(),
                    footer: isEditing.state?const AddTile(isTop: false):Container(),
                    children: todos.map((todo) =>ToDoTile(key: Key('${todo.id}'), todo: todo, isEditing: isEditing.state)).toList(),
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      ref.read(todosProvider.notifier).reorder(oldIndex, newIndex);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ToDoTile extends ConsumerWidget {
  const ToDoTile({Key? key, required this.todo, required this.isEditing}) : super(key: key);

  final ToDo todo;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isEditing?InkWell(
      onTap: ()=>showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String description = '';
          return AlertDialog(
            title: const Text('タスクを編集'),
            content: TextField(
              onChanged: (value){
                description = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: (){
                  ref.read(todosProvider.notifier).edit(todo.id, description);
                  Navigator.pop(context, 'OK');
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))
        ),
        child: ListTile(
            title: Text(todo.description, style: todo.isCompleted?const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xff777777)):
            const TextStyle(decoration: TextDecoration.none),),
            trailing: GestureDetector(
                onTap: ()=>ref.read(todosProvider.notifier).removeTodo(todo.id),
                child: const Icon(Icons.close, color: Colors.red,)
            )
        ),
      ),
    ):InkWell(
      onTap: ()=>ref.read(todosProvider.notifier).toggle(todo.id),
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))
        ),
        child: ListTile(
          title: Text(todo.description, style: todo.isCompleted?const TextStyle(decoration: TextDecoration.lineThrough, color: Color(0xff777777)):
          const TextStyle(decoration: TextDecoration.none),),
          trailing: todo.isCompleted?const Icon(Icons.check, color: Colors.green,):const SizedBox(),
        ),
      ),
    );
  }
}


class AddTile extends ConsumerWidget {
  const AddTile({Key? key, required this.isTop}) : super(key: key);
  final bool isTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))
      ),
      child: ListTile(
        onTap: ()=>showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            String description = '';
            return AlertDialog(
              title: const Text('タスクを追加'),
              content: TextField(
                onChanged: (value){
                  description = value;
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: (){
                    isTop?
                    ref.read(todosProvider.notifier).addTop(
                        ToDo(id: DateTime.now().millisecondsSinceEpoch, description: description, isCompleted: false)
                    ):ref.read(todosProvider.notifier).addBottom(
                        ToDo(id: DateTime.now().millisecondsSinceEpoch, description: description, isCompleted: false)
                    );
                    Navigator.pop(context, 'OK');
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        ),
        leading: const Icon(Icons.add),
        title: const Text('タスクを追加'),
      ),
    );
  }
}



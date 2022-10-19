import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

const List<ToDo> todosList = [
  ToDo(id: 0, description: 'task1', isCompleted: false),
  ToDo(id: 1, description: 'task2', isCompleted: false),
  ToDo(id: 2, description: 'task3', isCompleted: false),
  ToDo(id: 3, description: 'task4', isCompleted: false),
  ToDo(id: 4, description: 'task5', isCompleted: false),
];

class TodosNotifier extends StateNotifier<List<ToDo>> {
  TodosNotifier(): super(todosList);

  void addTop(ToDo todo) {
    state = [todo, ...state];
  }

  void addBottom(ToDo todo) {
    state = [...state, todo];
  }

  void removeTodo(int id) {
    state = [
      for (final todo in state)
        if(todo.id != id)
          todo,
    ];
  }

  void toggle(int id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
  }

  void edit(int id, String description){
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(description: description)
        else
          todo,
    ];
  }

  void reorder(int previousIndex, int newIndex) {
    List<ToDo> newList = [];
    for(int i = 0; i<state.length; i++){
      if(i!=previousIndex){
        newList.add(state[i]);
      }
    }
    newList.insert(newIndex, state[previousIndex]);
    state = newList;
  }
}

final todosProvider = StateNotifierProvider<TodosNotifier, List<ToDo>>((ref) {
  return TodosNotifier();
});

final editProvider = StateProvider<bool>((ref) => false);

final completedTodosProvider = Provider<List<ToDo>>((ref) {

  final todos = ref.watch(todosProvider);

  return todos.where((todo) => todo.isCompleted).toList();
});

final unfinishedTodosProvider = Provider<List<ToDo>>((ref) {

  final todos = ref.watch(todosProvider);

  return todos.where((todo) => !todo.isCompleted).toList();
});
class Todo {
  final int id;
  final int personId;
  final int status;
  final String text;

  Todo({
    required this.id,
    required this.personId,
    required this.status,
    required this.text,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      personId: json['person_id'],
      status: json['status'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'person_id': personId,
      'status': status,
      'text': text,
    };
  }
}

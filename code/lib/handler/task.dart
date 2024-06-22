class Task {
  int? id;
  String? title;
  String? description;
  String? date;
  String? priority;

  Task({this.id, this.title, this.description, this.date, this.priority});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'priority': priority
    };
  }
}

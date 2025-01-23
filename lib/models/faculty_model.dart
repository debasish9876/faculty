class Faculty {
  final String id;
  final String name;
  final String department;
  final String room;
  final String status;

  Faculty({
    required this.id,
    required this.name,
    required this.department,
    required this.room,
    required this.status,
  });

  // Factory to parse Firestore document
  factory Faculty.fromFirestore(Map<String, dynamic> data, String id) {
    return Faculty(
      id: id,
      name: data['name'],
      department: data['department'],
      room: data['room'],
      status: data['status'],
    );
  }

  // Convert Faculty object to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'department': department,
      'room': room,
      'status': status,
    };
  }
}

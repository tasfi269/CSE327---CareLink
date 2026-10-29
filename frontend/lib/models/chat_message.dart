enum MessageSender { user, assistant }

class MedicineItem {
  final String name;
  final String purpose;
  final String dosage;
  final String frequency;
  final String mealTiming;

  MedicineItem({
    required this.name,
    required this.purpose,
    required this.dosage,
    required this.frequency,
    required this.mealTiming,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      name: json['name'] ?? '',
      purpose: json['purpose'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      mealTiming: json['meal_timing'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'purpose': purpose,
      'dosage': dosage,
      'frequency': frequency,
      'meal_timing': mealTiming,
    };
  }
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final String? attachmentPath;
  final bool isImageAttachment;
  final List<MedicineItem>? medicines;
  final String? doctorRecommendation;
  final bool isThinking;
  final String? sessionId;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.attachmentPath,
    this.isImageAttachment = false,
    this.medicines,
    this.doctorRecommendation,
    this.isThinking = false,
    this.sessionId,
  });

  factory ChatMessage.user({
    required String text,
    String? attachmentPath,
    bool isImage = false,
    String? sessionId,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: text,
      timestamp: DateTime.now(),
      attachmentPath: attachmentPath,
      isImageAttachment: isImage,
      sessionId: sessionId,
    );
  }

  factory ChatMessage.assistant({
    required String text,
    List<MedicineItem>? medicines,
    String? doctorRecommendation,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.assistant,
      text: text,
      timestamp: timestamp ?? DateTime.now(),
      medicines: medicines,
      doctorRecommendation: doctorRecommendation,
      sessionId: sessionId,
    );
  }

  factory ChatMessage.thinking({String? sessionId}) {
    return ChatMessage(
      id: 'thinking',
      sender: MessageSender.assistant,
      text: '',
      timestamp: DateTime.now(),
      isThinking: true,
      sessionId: sessionId,
    );
  }
}

class ChatSessionSummary {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final String lastMessage;
  final bool hasPrescription;
  final String? doctorRecommendation;

  ChatSessionSummary({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.lastMessage = '',
    this.hasPrescription = false,
    this.doctorRecommendation,
  });

  factory ChatSessionSummary.fromJson(Map<String, dynamic> json) {
    return ChatSessionSummary(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Health Consultation',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messageCount: json['message_count'] is int
          ? json['message_count']
          : int.tryParse(json['message_count']?.toString() ?? '0') ?? 0,
      lastMessage: json['last_message']?.toString() ?? '',
      hasPrescription: json['has_prescription'] == true,
      doctorRecommendation: json['doctor_recommendation']?.toString(),
    );
  }
}

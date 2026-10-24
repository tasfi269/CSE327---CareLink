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
  });

  factory ChatMessage.user({
    required String text,
    String? attachmentPath,
    bool isImage = false,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: text,
      timestamp: DateTime.now(),
      attachmentPath: attachmentPath,
      isImageAttachment: isImage,
    );
  }

  factory ChatMessage.assistant({
    required String text,
    List<MedicineItem>? medicines,
    String? doctorRecommendation,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.assistant,
      text: text,
      timestamp: timestamp ?? DateTime.now(),
      medicines: medicines,
      doctorRecommendation: doctorRecommendation,
    );
  }

  factory ChatMessage.thinking() {
    return ChatMessage(
      id: 'thinking',
      sender: MessageSender.assistant,
      text: '',
      timestamp: DateTime.now(),
      isThinking: true,
    );
  }
}

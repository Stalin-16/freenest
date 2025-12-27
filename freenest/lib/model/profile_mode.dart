// import 'dart:convert';
import 'dart:convert';

class Profile {
  final int id;
  final String serviceTitle;
  final String serviceCategory;
  final String experienceRange;
  final int hourlyRate;
  final String tagline;
  final String? profileImage;
  final List<Deliverable> deliverables;
  final List<ProcessStep> processSteps;
  final List<Promise> promises;
  final List<Faq> faqs;
  final int rating;
  final int workOrderCount;
  final String reviewComments;

  Profile({
    required this.id,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.experienceRange,
    required this.hourlyRate,
    required this.tagline,
    this.profileImage,
    required this.deliverables,
    required this.processSteps,
    required this.promises,
    required this.faqs,
    required this.rating,
    required this.workOrderCount,
    required this.reviewComments,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      serviceTitle: map['serviceTitle'] ?? '',
      serviceCategory: map['serviceCategory'] ?? '',
      experienceRange: map['experienceRange'] ?? '',
      hourlyRate: map['hourlyRate'] ?? 0,
      tagline: map['tagline'] ?? '',
      profileImage: map['profileImage'] ?? '',
      deliverables: (jsonDecode(map['deliverables'] ?? '[]') as List)
          .map((d) => Deliverable.fromMap(d))
          .toList(),
      processSteps: (jsonDecode(map['processSteps'] ?? '[]') as List)
          .map((p) => ProcessStep.fromMap(p))
          .toList(),
      promises: (jsonDecode(map['promises'] ?? '[]') as List)
          .map((p) => Promise.fromMap(p))
          .toList(),
      faqs: (jsonDecode(map['faqs'] ?? '[]') as List)
          .map((f) => Faq.fromMap(f))
          .toList(),
      rating: map['overallRating'] ?? 0,
      reviewComments: map['reviewComments'] ?? '',
      workOrderCount: map['orderCount'] ?? 0,
    );
  }
}

class Deliverable {
  final String title;
  final String description;
  Deliverable({required this.title, required this.description});

  factory Deliverable.fromMap(Map<String, dynamic> map) {
    return Deliverable(
      title: map['title'],
      description: map['description'],
    );
  }
}

class ProcessStep {
  final String title;
  final String description;
  ProcessStep({required this.title, required this.description});

  factory ProcessStep.fromMap(Map<String, dynamic> map) {
    return ProcessStep(
      title: map['title'],
      description: map['description'],
    );
  }
}

class Promise {
  final bool checked;
  final String text;
  Promise({required this.checked, required this.text});

  factory Promise.fromMap(Map<String, dynamic> map) {
    return Promise(
      checked: map['checked'],
      text: map['text'],
    );
  }
}

class Faq {
  final String question;
  final String answer;
  Faq({required this.question, required this.answer});

  factory Faq.fromMap(Map<String, dynamic> map) {
    return Faq(
      question: map['question'],
      answer: map['answer'],
    );
  }
}

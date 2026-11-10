class MassageService {
  const MassageService({
    required this.name,
    required this.durationMinutes,
    required this.priceBaht,
  });

  final String name;
  final int durationMinutes;
  final int priceBaht;

  String get durationLabel => '$durationMinutes นาที';
}

class MassageMockData {
  static const List<MassageService> services = [
    MassageService(name: 'นวดไทย 60 นาที', durationMinutes: 60, priceBaht: 350),
    MassageService(name: 'นวดไทย 90 นาที', durationMinutes: 90, priceBaht: 500),
    MassageService(
      name: 'นวดน้ำมัน 60 นาที',
      durationMinutes: 60,
      priceBaht: 450,
    ),
    MassageService(
      name: 'นวดเท้า 60 นาที',
      durationMinutes: 60,
      priceBaht: 300,
    ),
    MassageService(name: 'อโรม่า 90 นาที', durationMinutes: 90, priceBaht: 650),
  ];

  static const List<String> staff = ['คุณมะลิ', 'คุณพิม', 'คุณอร'];

  static MassageService? findServiceMentionedIn(String text) {
    final normalizedText = _normalize(text);
    for (final service in services) {
      if (normalizedText.contains(_normalize(service.name))) {
        return service;
      }
    }
    return null;
  }

  static bool mentionsServiceType(String text) {
    final normalizedText = _normalize(text);
    return services.any(
      (service) =>
          normalizedText.contains(_normalize(service.name.split(' ').first)),
    );
  }

  static String get catalogForPrompt => services
      .map(
        (service) =>
            '- ${service.name}: ${service.durationMinutes} นาที, ${service.priceBaht} บาท',
      )
      .join('\n');

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}

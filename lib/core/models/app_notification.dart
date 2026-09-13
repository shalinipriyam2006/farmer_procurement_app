import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String titleEn;
  final String titleTa;
  final String messageEn;
  final String messageTa;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.titleEn,
    required this.titleTa,
    required this.messageEn,
    required this.messageTa,
    required this.timestamp,
    this.icon = Icons.notifications_rounded,
    this.color = const Color(0xFF1B5E20),
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      titleEn: json['titleEn'] ?? '',
      titleTa: json['titleTa'] ?? '',
      messageEn: json['messageEn'] ?? '',
      messageTa: json['messageTa'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      icon: Icons.notifications_rounded,
      color: const Color(0xFF1B5E20),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleEn': titleEn,
        'titleTa': titleTa,
        'messageEn': messageEn,
        'messageTa': messageTa,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  AppNotification copyWith({
    String? id,
    String? titleEn,
    String? titleTa,
    String? messageEn,
    String? messageTa,
    DateTime? timestamp,
    IconData? icon,
    Color? color,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleTa: titleTa ?? this.titleTa,
      messageEn: messageEn ?? this.messageEn,
      messageTa: messageTa ?? this.messageTa,
      timestamp: timestamp ?? this.timestamp,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
    );
  }
}

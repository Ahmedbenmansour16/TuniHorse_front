import 'package:flutter/material.dart';

class TrainerStat {
  final String label;
  final String value;
  final IconData icon;

  const TrainerStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class Rider {
  final String name;
  final String level;
  final String horsesCount;
  final String lastSession;
  final String phone;
  final String email;
  final Color color;

  const Rider({
    required this.name,
    required this.level,
    required this.horsesCount,
    required this.lastSession,
    required this.phone,
    required this.email,
    required this.color,
  });
}

class Horse {
  final String? id;
  final String name;
  final String race;
  final String age;
  final String owner;
  final String status;
  final Color color;
  final String? photoUrl;

  const Horse({
    this.id,
    required this.name,
    required this.race,
    required this.age,
    required this.owner,
    required this.status,
    required this.color,
    this.photoUrl,
  });
}

class LiveSession {
  final String? reportId;
  final String? workoutId;
  final Horse horse;
  final Rider rider;
  final String distance;
  final String duration;
  final String gait;
  final String speed;
  final String heartRate;
  final String status;
  final DateTime? startedAt;
  final int? durationSeconds;
  final double? distanceKm;
  final double? averageSpeedKmh;
  final double? maxSpeedKmh;
  final List<GaitStat> gaitAnalysis;
  final List<SpeedPoint> speedByKilometer;
  final CoachCommentInfo? coachComment;
  final String? riderComment;

  const LiveSession({
    this.reportId,
    this.workoutId,
    required this.horse,
    required this.rider,
    required this.distance,
    required this.duration,
    required this.gait,
    required this.speed,
    required this.heartRate,
    this.status = 'En direct',
    this.startedAt,
    this.durationSeconds,
    this.distanceKm,
    this.averageSpeedKmh,
    this.maxSpeedKmh,
    this.gaitAnalysis = const [],
    this.speedByKilometer = const [],
    this.coachComment,
    this.riderComment,
  });
}

class GaitStat {
  final String gait;
  final int minutes;
  final double distanceKm;
  final int percentage;

  const GaitStat({
    required this.gait,
    required this.minutes,
    required this.distanceKm,
    required this.percentage,
  });
}

class SpeedPoint {
  final int kilometer;
  final double speedKmh;

  const SpeedPoint({required this.kilometer, required this.speedKmh});
}

class CoachCommentInfo {
  final String coachName;
  final int? note;
  final String pointsForts;
  final String pointsAmeliorer;
  final String commentaire;

  const CoachCommentInfo({
    required this.coachName,
    this.note,
    required this.pointsForts,
    required this.pointsAmeliorer,
    required this.commentaire,
  });
}

class CourseInfo {
  final String? id;
  final DateTime? dateCourse;
  final String name;
  final String category;
  final String date;
  final String place;
  final String organisation;
  final String countdown;
  final Color color;

  const CourseInfo({
    this.id,
    this.dateCourse,
    required this.name,
    required this.category,
    required this.date,
    required this.place,
    this.organisation = '',
    required this.countdown,
    required this.color,
  });
}

class NotificationItem {
  final String type;
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  const NotificationItem({
    required this.type,
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class HealthReminder {
  final String title;
  final String due;
  final IconData icon;

  const HealthReminder({
    required this.title,
    required this.due,
    required this.icon,
  });
}

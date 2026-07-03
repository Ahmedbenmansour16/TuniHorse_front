import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class WorkoutsApiException implements Exception {
  final String message;

  const WorkoutsApiException(this.message);

  @override
  String toString() => message;
}

class WorkoutsApiClient {
  final http.Client _client;

  WorkoutsApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<RiderMonthStats> getMyMonthStats() async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.workouts}/my-month-stats',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return RiderMonthStats.fromJson(decoded);
    }

    return const RiderMonthStats.empty();
  }

  Future<List<LiveSession>> getMyHistory({int? limit}) async {
    final query = limit == null ? '' : '?limit=$limit';
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.workouts}/my-history$query',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_sessionFromJson)
          .toList();
    }

    return [];
  }

  Future<List<LiveSession>> getHorseHistory(String horseId) async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.workouts}/horse/$horseId',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_sessionFromJson)
          .toList();
    }

    return [];
  }

  Future<LiveSession> getReportByWorkout(LiveSession session) async {
    final workoutId = session.workoutId;
    if (workoutId == null || workoutId.isEmpty) return session;

    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.reports}/workout/$workoutId',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) return session;
    return _sessionFromReportJson(decoded, fallback: session);
  }

  LiveSession _sessionFromJson(Map<String, dynamic> json) {
    final horseJson = _asMap(json['horse']);
    final riderJson = _asMap(json['rider']);
    final distanceKm = _asDouble(json['distanceKm']);
    final durationSeconds = _asInt(json['durationSeconds']);
    final averageSpeedKmh = _asDouble(json['averageSpeedKmh']);
    final maxSpeedKmh = _asDouble(json['maxSpeedKmh']);
    final startedAt = DateTime.tryParse(json['startedAt']?.toString() ?? '');

    return LiveSession(
      workoutId: json['id']?.toString(),
      horse: _horseFromJson(horseJson),
      rider: _riderFromJson(riderJson),
      distance: _formatDistance(distanceKm),
      duration: _formatDuration(durationSeconds),
      gait: json['dominantGait']?.toString() ?? 'Trot',
      speed: _formatSpeed(averageSpeedKmh),
      heartRate: '--',
      status: _statusLabel(json['status']?.toString()),
      startedAt: startedAt,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      averageSpeedKmh: averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
    );
  }

  LiveSession _sessionFromReportJson(
    Map<String, dynamic> json, {
    required LiveSession fallback,
  }) {
    final horseJson = _asMap(json['horse']);
    final riderJson = _asMap(json['rider']);
    final distanceKm = _asDouble(json['distanceKm']);
    final durationSeconds = _asInt(json['durationSeconds']);
    final averageSpeedKmh = _asDouble(json['averageSpeedKmh']);
    final maxSpeedKmh = _asDouble(json['maxSpeedKmh']);
    final dateSeance = DateTime.tryParse(json['dateSeance']?.toString() ?? '');
    final coachJson = _asMap(json['coachComment']);
    final riderCommentJson = _asMap(json['riderComment']);

    return LiveSession(
      workoutId: json['workoutId']?.toString() ?? fallback.workoutId,
      horse: horseJson.isEmpty ? fallback.horse : _horseFromJson(horseJson),
      rider: riderJson.isEmpty ? fallback.rider : _riderFromJson(riderJson),
      distance: _formatDistance(distanceKm),
      duration: _formatDuration(durationSeconds),
      gait: json['dominantGait']?.toString() ?? fallback.gait,
      speed: _formatSpeed(averageSpeedKmh),
      heartRate: fallback.heartRate,
      status: fallback.status,
      startedAt: dateSeance ?? fallback.startedAt,
      durationSeconds: durationSeconds,
      distanceKm: distanceKm,
      averageSpeedKmh: averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
      gaitAnalysis: _gaitAnalysisFromJson(json['gaitAnalysis']),
      coachComment: coachJson.isEmpty
          ? fallback.coachComment
          : _coachCommentFromJson(coachJson),
      riderComment:
          riderCommentJson['commentaire']?.toString() ?? fallback.riderComment,
    );
  }

  Horse _horseFromJson(Map<String, dynamic> json) {
    final photoUrl = json['photoUrl']?.toString();
    return Horse(
      id: json['id']?.toString(),
      name: json['nom']?.toString() ?? 'Cheval',
      race: json['race']?.toString() ?? 'Race non precisee',
      age: _ageLabel(json['age']),
      owner: '',
      status: 'Actif',
      color: _horseColor(json['nom']?.toString() ?? ''),
      photoUrl: _absolutePhotoUrl(photoUrl),
    );
  }

  Rider _riderFromJson(Map<String, dynamic> json) {
    return Rider(
      name: json['nomComplet']?.toString() ?? 'Cavalier',
      level: 'Cavalier',
      horsesCount: '',
      lastSession: '',
      phone: '',
      email: json['email']?.toString() ?? '',
      color: AppColors.green,
    );
  }

  List<GaitStat> _gaitAnalysisFromJson(dynamic value) {
    if (value is! List) return [];

    return value.whereType<Map<String, dynamic>>().map((json) {
      return GaitStat(
        gait: json['gait']?.toString() ?? 'Allure',
        minutes: _asInt(json['minutes']),
        distanceKm: _asDouble(json['distanceKm']),
        percentage: _asInt(json['percentage']),
      );
    }).toList();
  }

  CoachCommentInfo _coachCommentFromJson(Map<String, dynamic> json) {
    final coachJson = _asMap(json['coach']);
    return CoachCommentInfo(
      coachName: coachJson['nomComplet']?.toString() ?? 'Coach',
      note: json['note'] == null ? null : _asInt(json['note']),
      pointsForts: json['pointsForts']?.toString() ?? '',
      pointsAmeliorer: json['pointsAmeliorer']?.toString() ?? '',
      commentaire: json['commentaire']?.toString() ?? '',
    );
  }

  Future<http.Response> _send({
    required String method,
    required String path,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const WorkoutsApiException('Session expiree. Reconnectez-vous.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WorkoutsApiException(_errorMessage(response.body));
      }

      return response;
    } on TimeoutException {
      throw const WorkoutsApiException('Le serveur ne repond pas.');
    } on WorkoutsApiException {
      rethrow;
    } catch (error) {
      throw WorkoutsApiException('Impossible de contacter le serveur: $error');
    }
  }

  String _errorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is List) return message.join('\n');
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {}

    return 'Erreur serveur pendant le chargement des entrainements.';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : {};
  }

  int _asInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDistance(double value) {
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} km';
  }

  String _formatSpeed(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')} km/h';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${_two(hours)}:${_two(minutes)}:${_two(secs)}';
    }

    return '${_two(minutes)}:${_two(secs)}';
  }

  String _ageLabel(dynamic age) {
    final parsed = _asInt(age);
    return parsed <= 0 ? '--' : '$parsed ans';
  }

  String _statusLabel(String? status) {
    return status == 'FINISHED' ? 'Terminee' : 'En direct';
  }

  String? _absolutePhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return photoUrl;
    return '${ApiConstants.baseUrl}$photoUrl';
  }

  Color _horseColor(String name) {
    final colors = [
      const Color(0xFF8B4B24),
      const Color(0xFF8F9182),
      const Color(0xFF3E2518),
      const Color(0xFFD8D0C4),
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void close() {
    _client.close();
  }
}

class RiderMonthStats {
  final int seances;
  final double distanceKm;
  final int durationSeconds;
  final int chevaux;

  const RiderMonthStats({
    required this.seances,
    required this.distanceKm,
    required this.durationSeconds,
    required this.chevaux,
  });

  const RiderMonthStats.empty()
    : seances = 0,
      distanceKm = 0,
      durationSeconds = 0,
      chevaux = 0;

  factory RiderMonthStats.fromJson(Map<String, dynamic> json) {
    return RiderMonthStats(
      seances: int.tryParse(json['seances']?.toString() ?? '') ?? 0,
      distanceKm: double.tryParse(json['distanceKm']?.toString() ?? '') ?? 0,
      durationSeconds:
          int.tryParse(json['durationSeconds']?.toString() ?? '') ?? 0,
      chevaux: int.tryParse(json['chevaux']?.toString() ?? '') ?? 0,
    );
  }

  List<TrainerStat> toTrainerStats() {
    return [
      TrainerStat(
        label: 'Seances',
        value: '$seances',
        icon: Icons.timer_outlined,
      ),
      TrainerStat(label: 'Distance', value: _distanceLabel, icon: Icons.route),
      TrainerStat(label: 'Duree', value: _durationLabel, icon: Icons.schedule),
      TrainerStat(label: 'Chevaux', value: '$chevaux', icon: Icons.hdr_strong),
    ];
  }

  String get _distanceLabel {
    final rounded = distanceKm % 1 == 0
        ? distanceKm.toStringAsFixed(0)
        : distanceKm.toStringAsFixed(1).replaceAll('.', ',');
    return '$rounded km';
  }

  String get _durationLabel {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }
}

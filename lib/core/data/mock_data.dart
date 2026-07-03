import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';

const trainerStats = [
  TrainerStat(label: 'Cavaliers', value: '8', icon: Icons.groups_outlined),
  TrainerStat(label: 'Chevaux', value: '12', icon: Icons.hdr_strong),
  TrainerStat(label: 'Séances', value: '23', icon: Icons.timer_outlined),
  TrainerStat(label: 'Rapports', value: '24', icon: Icons.article_outlined),
];

const riders = [
  Rider(
    name: 'Camille Martin',
    level: 'Niveau 4 - Galop 4',
    horsesCount: '3 chevaux',
    lastSession: '18/05/2026',
    phone: '06 12 34 56 78',
    email: 'camille@gmail.com',
    color: Color(0xFFE08A53),
  ),
  Rider(
    name: 'Julie François',
    level: 'Niveau 3 - Galop 3',
    horsesCount: '2 chevaux',
    lastSession: '18/05/2026',
    phone: '06 10 22 44 80',
    email: 'julie@gmail.com',
    color: Color(0xFFC07954),
  ),
  Rider(
    name: 'Antoine Dubois',
    level: 'Niveau 5 - Galop 5',
    horsesCount: '4 chevaux',
    lastSession: '17/05/2026',
    phone: '06 18 44 20 10',
    email: 'antoine@gmail.com',
    color: Color(0xFF315941),
  ),
  Rider(
    name: 'Léa Bernard',
    level: 'Niveau 2 - Galop 2',
    horsesCount: '1 cheval',
    lastSession: '16/05/2026',
    phone: '06 16 33 42 12',
    email: 'lea@gmail.com',
    color: Color(0xFFAF725F),
  ),
  Rider(
    name: 'Thomas Leroy',
    level: 'Niveau 4 - Galop 4',
    horsesCount: '2 chevaux',
    lastSession: '15/05/2026',
    phone: '06 11 15 26 92',
    email: 'thomas@gmail.com',
    color: Color(0xFF526E82),
  ),
];

const horses = [
  Horse(
    name: 'Éclipse',
    race: 'Pur-sang arabe',
    age: '9 ans',
    owner: 'Camille Martin',
    status: 'Actif',
    color: Color(0xFF8B4B24),
  ),
  Horse(
    name: 'Valkyrie',
    race: 'Selle Français',
    age: '6 ans',
    owner: 'Julie François',
    status: 'Actif',
    color: Color(0xFF8F9182),
  ),
  Horse(
    name: 'Orion',
    race: 'Anglo-arabe',
    age: '8 ans',
    owner: 'Antoine Dubois',
    status: 'Actif',
    color: Color(0xFF3E2518),
  ),
  Horse(
    name: 'Nébuleuse',
    race: 'OC',
    age: '7 ans',
    owner: 'Léa Bernard',
    status: 'Repos',
    color: Color(0xFFD8D0C4),
  ),
];

final liveSessions = [
  LiveSession(
    horse: horses[0],
    rider: riders[0],
    distance: '12,45 km',
    duration: '01:08:24',
    gait: 'Trot',
    speed: '12,45 km/h',
    heartRate: '145 bpm',
  ),
  LiveSession(
    horse: horses[1],
    rider: riders[1],
    distance: '8,21 km',
    duration: '00:54:12',
    gait: 'Galop',
    speed: '14,10 km/h',
    heartRate: '152 bpm',
  ),
  LiveSession(
    horse: horses[2],
    rider: riders[2],
    distance: '6,32 km',
    duration: '00:42:18',
    gait: 'Pas',
    speed: '7,25 km/h',
    heartRate: '132 bpm',
  ),
];

const courses = [
  CourseInfo(
    name: 'Concours de Sousse',
    category: 'Saut',
    date: '20/06/2026',
    place: 'Club Équestre Sousse',
    countdown: '5j 12h',
    color: Color(0xFF8B4B24),
  ),
  CourseInfo(
    name: 'Endurance de Mahdia',
    category: 'Endurance',
    date: '10/07/2026',
    place: 'Mahdia',
    countdown: '25j',
    color: Color(0xFF8F9182),
  ),
  CourseInfo(
    name: 'Jumping de Tunis',
    category: 'Saut',
    date: '18/07/2026',
    place: 'Tunis',
    countdown: '33j',
    color: Color(0xFF3E2518),
  ),
  CourseInfo(
    name: 'Championnat national',
    category: 'Dressage',
    date: '01/08/2026',
    place: 'Kantaoui',
    countdown: '47j',
    color: Color(0xFFD8D0C4),
  ),
];

const healthReminders = [
  HealthReminder(
    title: 'Ferrage',
    due: 'Dans 10 jours',
    icon: Icons.build_outlined,
  ),
  HealthReminder(
    title: 'Vaccin grippe',
    due: 'Dans 25 jours',
    icon: Icons.vaccines_outlined,
  ),
  HealthReminder(
    title: 'Vermifuge',
    due: 'Dans 30 jours',
    icon: Icons.medication_outlined,
  ),
  HealthReminder(
    title: 'Visite vétérinaire',
    due: 'Dans 35 jours',
    icon: Icons.local_hospital_outlined,
  ),
];

const notifications = [
  NotificationItem(
    type: 'Santé',
    title: "Vaccin d'Éclipse dans 5 jours",
    time: '09:10',
    icon: Icons.favorite_outline,
    color: AppColors.green,
  ),
  NotificationItem(
    type: 'Séance',
    title: 'Camille a lancé une séance avec Éclipse',
    time: '10:21',
    icon: Icons.timer_outlined,
    color: AppColors.gold,
  ),
  NotificationItem(
    type: 'SOS',
    title: 'Alerte SOS reçue sur le parcours',
    time: '16:42',
    icon: Icons.warning_amber_rounded,
    color: AppColors.danger,
  ),
  NotificationItem(
    type: 'Course',
    title: 'Concours de Sousse dans 5 jours',
    time: 'Hier',
    icon: Icons.emoji_events_outlined,
    color: AppColors.amber,
  ),
];

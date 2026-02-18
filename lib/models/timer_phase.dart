import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum TimerPhase {
  idle,
  preparation,
  work,
  rest,
  tabataRest,
  segmentRest,
  finished;

  String get displayName {
    switch (this) {
      case TimerPhase.idle:
        return 'Listo';
      case TimerPhase.preparation:
        return 'Preparación';
      case TimerPhase.work:
        return 'Trabajo';
      case TimerPhase.rest:
        return 'Descanso';
      case TimerPhase.tabataRest:
        return 'Descanso Tabata';
      case TimerPhase.segmentRest:
        return 'Descanso entre bloques';
      case TimerPhase.finished:
        return 'Terminado';
    }
  }

  Color get color {
    switch (this) {
      case TimerPhase.idle:
        return AppColors.textSecondary;
      case TimerPhase.preparation:
        return AppColors.preparation;
      case TimerPhase.work:
        return AppColors.work;
      case TimerPhase.rest:
        return AppColors.rest;
      case TimerPhase.tabataRest:
        return AppColors.tabataRest;
      case TimerPhase.segmentRest:
        return AppColors.tabataRest;
      case TimerPhase.finished:
        return AppColors.finished;
    }
  }
}

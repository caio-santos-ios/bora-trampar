import '../../models/appointment_model.dart';
import '../../models/profile_professional_model.dart';

class AvailabilityHelper {
  static int _getWeekdayIndex(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 0;
      case DateTime.tuesday:
        return 1;
      case DateTime.wednesday:
        return 2;
      case DateTime.thursday:
        return 3;
      case DateTime.friday:
        return 4;
      case DateTime.saturday:
        return 5;
      case DateTime.sunday:
        return 6;
      default:
        return 0;
    }
  }

  static ProfessionalWorkingDayModel? getWorkingDayForDate(
      ProfileProfessionalModel profile, DateTime date) {
    if (profile.workingHours.isEmpty) return null;

    final targetIndex = _getWeekdayIndex(date);

    for (final wh in profile.workingHours) {
      if (wh.dayOfWeek == targetIndex) return wh;
    }

    final dayNameMatches = {
      0: 'seg',
      1: 'ter',
      2: 'qua',
      3: 'qui',
      4: 'sex',
      5: 'sáb',
      6: 'dom',
    };

    final targetPrefix = dayNameMatches[targetIndex] ?? '';
    for (final wh in profile.workingHours) {
      if (wh.dayName.toLowerCase().contains(targetPrefix)) {
        return wh;
      }
    }

    return null;
  }

  static bool isDayAvailable(ProfileProfessionalModel profile, DateTime date) {
    if (!profile.isAvailableNow) return false;

    final wh = getWorkingDayForDate(profile, date);
    if (wh == null) return true;

    return wh.isActive;
  }

  static int? _parseTimeToMinutes(String timeStr) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
    if (match != null) {
      final h = int.tryParse(match.group(1) ?? '') ?? 0;
      final m = int.tryParse(match.group(2) ?? '') ?? 0;
      return h * 60 + m;
    }
    return null;
  }

  static bool isTimeSlotAvailable(
      ProfileProfessionalModel profile, DateTime date, String timeSlot) {
    if (!isDayAvailable(profile, date)) return false;

    if (timeSlot.toLowerCase().contains('comercial')) return true;

    final slotMinutes = _parseTimeToMinutes(timeSlot);
    if (slotMinutes == null) return true;

    final wh = getWorkingDayForDate(profile, date);
    if (wh == null) return true;

    final startMinutes = _parseTimeToMinutes(wh.startHour) ?? (8 * 60);
    final endMinutes = _parseTimeToMinutes(wh.endHour) ?? (18 * 60);

    if (slotMinutes < startMinutes || slotMinutes >= endMinutes) {
      return false;
    }

    if (wh.breakStart.isNotEmpty && wh.breakEnd.isNotEmpty) {
      final breakStart = _parseTimeToMinutes(wh.breakStart);
      final breakEnd = _parseTimeToMinutes(wh.breakEnd);

      if (breakStart != null && breakEnd != null) {
        if (slotMinutes >= breakStart && slotMinutes < breakEnd) {
          return false;
        }
      }
    }

    return true;
  }

  static bool hasAppointmentConflict(
    List<AppointmentModel> appointments,
    String professionalId,
    DateTime date,
    String timeSlot,
  ) {
    if (appointments.isEmpty || professionalId.isEmpty) return false;

    final slotMinutes = _parseTimeToMinutes(timeSlot);

    for (final apt in appointments) {
      if (apt.profissionalId != professionalId) continue;

      final s = apt.status.toLowerCase();
      if (s == 'cancelled' ||
          s == 'declined' ||
          s == 'cancelado' ||
          s == 'recusado') {
        continue;
      }

      final isSameDay = apt.date.year == date.year &&
          apt.date.month == date.month &&
          apt.date.day == date.day;

      if (!isSameDay) continue;

      if (slotMinutes != null) {
        final aptMinutes = _parseTimeToMinutes(apt.hour);
        if (aptMinutes != null) {
          if ((slotMinutes - aptMinutes).abs() < 60) {
            return true;
          }
        }
      } else {
        if (apt.hour.trim().isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  static bool isProfessionalAvailable({
    required ProfileProfessionalModel? profile,
    required DateTime date,
    required String timeSlot,
    required List<AppointmentModel> appointments,
    required String proUserId,
  }) {
    if (profile != null) {
      if (!profile.isAvailableNow) return false;
      if (!isDayAvailable(profile, date)) return false;
      if (!isTimeSlotAvailable(profile, date, timeSlot)) return false;
    }

    if (hasAppointmentConflict(appointments, proUserId, date, timeSlot)) {
      return false;
    }

    return true;
  }
}

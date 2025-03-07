import 'dart:math';

const THIEN_CAN_LIST = [
  'Giáp',
  'Ất',
  'Bính',
  'Đinh',
  'Mậu',
  'Kỷ',
  'Canh',
  'Tân',
  'Nhâm',
  'Quý'
];
const DIA_CHI_LIST = [
  'Tý',
  'Sửu',
  'Dần',
  'Mão',
  'Thìn',
  'Tỵ',
  'Ngọ',
  'Mùi',
  'Thân',
  'Dậu',
  'Tuất',
  'Hợi'
];

const TIET_KHI_LIST = [
  "Lập Xuân",
  "Vũ Thủy",
  "Kinh Trập",
  "Xuân Phân",
  "Thanh Minh",
  "Cốc Vũ",
  "Lập Hạ",
  "Tiểu Mãn",
  "Mang Chủng",
  "Hạ Chí",
  "Tiểu Thử",
  "Đại Thử",
  "Lập Thu",
  "Xử Thử",
  "Bạch Lộ",
  "Thu Phân",
  "Hàn Lộ",
  "Sương Giáng",
  "Lập Đông",
  "Tiểu Tuyết",
  "Đại Tuyết",
  "Đông Chí",
  "Tiểu Hàn",
  "Đại Hàn"
];

int jdFromDate(int dd, int mm, int yy) {
  int a, y, m, jd;
  a = ((14 - mm) / 12).floor();
  y = yy + 4800 - a;
  m = mm + 12 * a - 3;
  jd = dd +
      ((153 * m + 2) / 5).floor() +
      365 * y +
      (y / 4).floor() -
      (y / 100).floor() +
      (y / 400).floor() -
      32045;
  if (jd < 2299161) {
    jd = dd + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - 32083;
  }
  return jd;
}

Map<String, int> jdToDate(int jd) {
  int a, b, c, d, e, m, day, month, year;
  if (jd > 2299160) {
    a = jd + 32044;
    b = ((4 * a + 3) / 146097).floor();
    c = a - ((b * 146097) / 4).floor();
  } else {
    b = 0;
    c = jd + 32082;
  }
  d = ((4 * c + 3) / 1461).floor();
  e = c - ((1461 * d) / 4).floor();
  m = ((5 * e + 2) / 153).floor();
  day = e - ((153 * m + 2) / 5).floor() + 1;
  month = m + 3 - 12 * (m / 10).floor();
  year = b * 100 + d - 4800 + (m / 10).floor();
  return {'day': day, 'month': month, 'year': year};
}

int getNewMoonDay(int k, int timeZone) {
  double T, T2, T3, dr, Jd1, M, Mpr, F, C1, deltat, JdNew;
  T = k / 1236.85;
  T2 = T * T;
  T3 = T2 * T;
  dr = 3.141592653589793 / 180;
  Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
  Jd1 = Jd1 + 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
  M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3;
  Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
  F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
  C1 = (0.1734 - 0.000393 * T) * sin(M * dr) + 0.0021 * sin(2 * dr * M);
  C1 = C1 - 0.4068 * sin(Mpr * dr) + 0.0161 * sin(2 * dr * Mpr);
  C1 = C1 - 0.0004 * sin(3 * dr * Mpr);
  C1 = C1 + 0.0104 * sin(2 * dr * F) - 0.0051 * sin(dr * (M + Mpr));
  C1 = C1 - 0.0074 * sin(dr * (M - Mpr)) + 0.0004 * sin(dr * (2 * F + M));
  C1 = C1 - 0.0004 * sin(dr * (2 * F - M)) - 0.0006 * sin(dr * (2 * F + Mpr));
  C1 = C1 + 0.0010 * sin(dr * (2 * F - Mpr)) + 0.0005 * sin(dr * (2 * Mpr + M));
  if (T < -11) {
    deltat = 0.001 +
        0.000839 * T +
        0.0002261 * T2 -
        0.00000845 * T3 -
        0.000000081 * T * T3;
  } else {
    deltat = -0.000278 + 0.000265 * T + 0.000262 * T2;
  }
  JdNew = Jd1 + C1 - deltat;
  return (JdNew + 0.5 + timeZone / 24).floor();
}

int getSunLongitude(int jdn, int timeZone) {
  double T, T2, dr, M, L0, DL, L;
  T = (jdn - 2451545.5 - timeZone / 24) / 36525;
  T2 = T * T;
  dr = 3.141592653589793 / 180;
  M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2;
  L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2;
  DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * M);
  DL = DL +
      (0.019993 - 0.000101 * T) * sin(dr * 2 * M) +
      0.000290 * sin(dr * 3 * M);
  L = L0 + DL;
  L = L * dr;
  L = L - 3.141592653589793 * 2 * (L / (3.141592653589793 * 2)).floor();
  return (L / 3.141592653589793 * 6).floor();
}

int getLunarMonth11(int yy, int timeZone) {
  int k, off, nm, sunLong;
  off = jdFromDate(31, 12, yy) - 2415021;
  k = (off / 29.530588853).floor();
  nm = getNewMoonDay(k, timeZone);
  sunLong = getSunLongitude(nm, timeZone);
  if (sunLong >= 9) {
    nm = getNewMoonDay(k - 1, timeZone);
  }
  return nm;
}

int getLeapMonthOffset(double a11, int timeZone) {
  int k, last, arc, i;
  k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
  last = 0;
  i = 1;
  arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
  do {
    last = arc;
    i++;
    arc = getSunLongitude(getNewMoonDay(k + i, timeZone), timeZone);
  } while (arc != last && i < 14);
  return i - 1;
}

Map<String, dynamic> convertSolar2Lunar(int dd, int mm, int yy, int timeZone) {
  int k,
      dayNumber,
      monthStart,
      a11,
      b11,
      lunarDay,
      lunarMonth,
      lunarYear,
      lunarLeap;
  dayNumber = jdFromDate(dd, mm, yy);
  k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
  monthStart = getNewMoonDay(k + 1, timeZone);
  if (monthStart > dayNumber) {
    monthStart = getNewMoonDay(k, timeZone);
  }
  a11 = getLunarMonth11(yy, timeZone);
  b11 = a11;
  if (a11 >= monthStart) {
    lunarYear = yy;
    a11 = getLunarMonth11(yy - 1, timeZone);
  } else {
    lunarYear = yy + 1;
    b11 = getLunarMonth11(yy + 1, timeZone);
  }
  lunarDay = dayNumber - monthStart + 1;
  int diff = ((monthStart - a11) / 29).floor();
  lunarLeap = 0;
  lunarMonth = diff + 11;
  if (b11 - a11 > 365) {
    int leapMonthDiff = getLeapMonthOffset(a11.toDouble(), timeZone);
    if (diff >= leapMonthDiff) {
      lunarMonth = diff + 10;
      if (diff == leapMonthDiff) {
        lunarLeap = 1;
      }
    }
  }
  if (lunarMonth > 12) {
    lunarMonth = lunarMonth - 12;
  }
  if (lunarMonth >= 11 && diff < 4) {
    lunarYear -= 1;
  }
  String canChiDate = getCanChiDateByJd(dayNumber);
  String canChiMonth = getCanChiMonth(lunarMonth, lunarYear);
  String canChiYear = getCanChiYear(lunarYear);
  Map<String, bool> isPhaDate = calculatePhaDate(
      jdDate: dayNumber, lunarMonth: lunarMonth, year: lunarYear);

  return {
    'lunarDay': lunarDay,
    'lunarMonth': lunarMonth,
    'lunarYear': lunarYear,
    'lunarLeap': lunarLeap,
    'canChiDate': canChiDate,
    'canchiMonth': canChiMonth,
    'canChiYear': canChiYear,
    'isNguyetPha': isPhaDate['isNguyetPha'],
    'isTuePha': isPhaDate['isTuePha'],
  };
}

Map<String, int> convertLunar2Solar(Map<String, dynamic> lunarDate) {
  int k, a11, b11, off, leapOff, leapMonth, monthStart;
  int lunarDay = lunarDate['lunarDay'];
  int lunarMonth = lunarDate['lunarMonth'];
  int lunarYear = lunarDate['lunarYear'];
  int lunarLeap = lunarDate['lunarLeap'];
  int timeZone = lunarDate['timeZone'] ?? 7;
  if (lunarMonth < 11) {
    a11 = getLunarMonth11(lunarYear - 1, timeZone);
    b11 = getLunarMonth11(lunarYear, timeZone);
  } else {
    a11 = getLunarMonth11(lunarYear, timeZone);
    b11 = getLunarMonth11(lunarYear + 1, timeZone);
  }
  off = lunarMonth - 11;
  if (off < 0) {
    off += 12;
  }
  if (b11 - a11 > 365) {
    leapOff = getLeapMonthOffset(a11.toDouble(), timeZone);
    leapMonth = leapOff - 2;
    if (leapMonth < 0) {
      leapMonth += 12;
    }
    if (lunarLeap != 0 && lunarMonth != leapMonth) {
      return {'day': 0, 'month': 0, 'year': 0};
    } else if (lunarLeap != 0 || off >= leapOff) {
      off += 1;
    }
  }
  k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
  monthStart = getNewMoonDay(k + off, timeZone);
  return jdToDate(monthStart + lunarDay - 1);
}

String getCanChiYear(int year) {
  return '${THIEN_CAN_LIST[(year + 6) % 10]} ${DIA_CHI_LIST[(year + 8) % 12]}';
}

String getCanChiDateByJd(int jd) {
  String can = THIEN_CAN_LIST[(jd + 9) % 10];
  String chi = DIA_CHI_LIST[(jd + 1) % 12];
  return '$can $chi';
}

String getCanChiMonth(int lunarMonth, int lunarYear) {
  String can = THIEN_CAN_LIST[(lunarYear * 12 + lunarMonth + 3) % 10];
  String chi = DIA_CHI_LIST[(lunarMonth + 1) % 12];
  return '$can $chi';
}

DateTime calculateLichLapXuan(int year) {
  // Dữ liệu cơ bản:
  const baseYear = 1900;
  final baseDate =
      DateTime(baseYear, 2, 4); // Lập Xuân của năm 1900 là 4 tháng 2
  const daysPerYear =
      365.2422; // Số ngày trung bình trong năm theo quỹ đạo Trái Đất

  // Tính toán số năm cách từ năm 1900
  final differenceInYears = year - baseYear;

  // Tính tổng số ngày đã qua kể từ năm 1900
  final totalDaysPassed = differenceInYears * daysPerYear;

  // Tạo đối tượng ngày mới dựa trên số ngày đã qua
  final lapXuanDate = baseDate.add(Duration(days: totalDaysPassed.round()));

  // Trả về ngày Lập Xuân (kết quả là một đối tượng Date)
  return lapXuanDate;
}

int tietKhiIndexToDiaChiMonthIndex(int index) {
  if (index < 0) {
    throw Exception("index < 0");
  }

  if (index >= TIET_KHI_LIST.length) {
    throw Exception("index shoud be <= 23");
  }

  // Tháng Dần index = 2 là Lập Xuân & Vũ Thuỷ, index = 0 và 1
  // Tháng Dần cũng là tháng 1 âm lịch theo lịch vạn niên
  return ((index + 2) ~/ 2) + 1;
}

Map<String, String> calculateTietKhi(DateTime inputDate) {
  int year = inputDate.year;
  final lichLapXuan = calculateLichLapXuan(year);

  // Tính số ngày đã trôi qua kể từ ngày Lập Xuân
  final daysSinceLapXuan = (inputDate.difference(lichLapXuan).inDays);

  // Xác định tiết khí dựa trên số ngày đã trôi qua
  final tietKhiIndex = (daysSinceLapXuan / 15.2184).floor();
  var realTietKhiIndex = tietKhiIndex;
  if (realTietKhiIndex < 0) {
    realTietKhiIndex = TIET_KHI_LIST.length + tietKhiIndex;
  } else if (tietKhiIndex >= TIET_KHI_LIST.length - 1) {
    realTietKhiIndex = tietKhiIndex % TIET_KHI_LIST.length;
  } else {
    realTietKhiIndex = tietKhiIndex;
  }

  final tietKhi = TIET_KHI_LIST[realTietKhiIndex];

  final diaChiMonthIndex = tietKhiIndexToDiaChiMonthIndex(realTietKhiIndex);
  final virtualLunarMonth = diaChiMonthIndex - 1;
  var virtualLunarYear = inputDate.year;
  if (inputDate.compareTo(lichLapXuan) == -1) {
    virtualLunarYear -= 1;
  }
  final canChiYear = getCanChiYear(virtualLunarYear);
  final canChiMonth = getCanChiMonth(virtualLunarMonth, virtualLunarYear);

  return {
    'tietKhi': tietKhi,
    'canChiYear': canChiYear,
    'canChiMonth': canChiMonth
  };
}

int calculateXungKhacDiaChi(int diaChiIndex) {
  //Index của Địa chi + 6
  return (diaChiIndex + 1 + 6) % 12 - 1;
}

Map<String, bool> calculatePhaDate(
    {required int jdDate, required int lunarMonth, required int year}) {
  bool isNguyetPha = false;
  bool isTuePha = false;

  int dayDiaChiIndex = (jdDate + 1) % 12;
  int monthDiaChiIndex = (lunarMonth + 1) % 12;
  int yearDiaChiIndex = (year + 8) % 12;

  int xungKhacIndex = calculateXungKhacDiaChi(dayDiaChiIndex);

  isNguyetPha = xungKhacIndex == monthDiaChiIndex;
  isTuePha = xungKhacIndex == yearDiaChiIndex;

  return {
    "isNguyetPha": isNguyetPha,
    "isTuePha": isTuePha,
  };
}

use chrono::{DateTime, NaiveDate, Utc};

const THIEN_CAN_LIST: [&str; 10] = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"];
const DIA_CHI_LIST: [&str; 12] = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"];
const TIET_KHI_LIST: [&str; 24] = [
    "Lập Xuân", "Vũ Thủy", "Kinh Trập", "Xuân Phân",
    "Thanh Minh", "Cốc Vũ", "Lập Hạ", "Tiểu Mãn",
    "Mang Chủng", "Hạ Chí", "Tiểu Thử", "Đại Thử",
    "Lập Thu", "Xử Thử", "Bạch Lộ", "Thu Phân",
    "Hàn Lộ", "Sương Giáng", "Lập Đông", "Tiểu Tuyết",
    "Đại Tuyết", "Đông Chí", "Tiểu Hàn", "Đại Hàn"
];

fn jd_from_date(dd: i32, mm: i32, yy: i32) -> i32 {
    let a = (14 - mm) / 12;
    let y = yy + 4800 - a;
    let m = mm + 12 * a - 3;
    let mut jd = dd + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
    if jd < 2299161 {
        jd = dd + (153 * m + 2) / 5 + 365 * y + y / 4 - 32083;
    }
    jd
}

fn jd_to_date(jd: i32) -> (i32, i32, i32) {
    let mut a, b, c, d, e, m, day, month, year;
    if jd > 2299160 { // After 5/10/1582, Gregorian calendar
        a = jd + 32044;
        b = (4 * a + 3) / 146097;
        c = a - (b * 146097) / 4;
    } else {
        b = 0;
        c = jd + 32082;
    }
    d = (4 * c + 3) / 1461;
    e = c - (1461 * d) / 4;
    m = (5 * e + 2) / 153;
    day = e - (153 * m + 2) / 5 + 1;
    month = m + 3 - 12 * (m / 10);
    year = b * 100 + d - 4800 + (m / 10);
    (day, month, year)
}

fn get_new_moon_day(k: f64, time_zone: f64) -> i32 {
    let t = k / 1236.85; // Time in Julian centuries from 1900 January 0.5
    let t2 = t * t;
    let t3 = t2 * t;
    let dr = std::f64::consts::PI / 180.0;
    let jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    let jd1 = jd1 + 0.00033 * (166.56 + 132.87 * t - 0.009173 * t2) * dr.sin(); // Mean new moon
    let m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3; // Sun's mean anomaly
    let mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3; // Moon's mean anomaly
    let f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3; // Moon's argument of latitude
    let c1 = (0.1734 - 0.000393 * t) * m.sin() * dr + 0.0021 * (2.0 * dr * m).sin();
    let c1 = c1 - 0.4068 * mpr.sin() * dr + 0.0161 * (dr * 2.0 * mpr).sin();
    let c1 = c1 - 0.0004 * (dr * 3.0 * mpr).sin();
    let c1 = c1 + 0.0104 * (dr * 2.0 * f).sin() - 0.0051 * (dr * (m + mpr)).sin();
    let c1 = c1 - 0.0074 * (dr * (m - mpr)).sin() + 0.0004 * (dr * (2.0 * f + m)).sin();
    let c1 = c1 - 0.0004 * (dr * (2.0 * f - m)).sin() - 0.0006 * (dr * (2.0 * f + mpr)).sin();
    let c1 = c1 + 0.0010 * (dr * (2.0 * f - mpr)).sin() + 0.0005 * (dr * (2.0 * mpr + m)).sin();
    let deltat;
    if t < -11.0 {
        deltat = 0.001 + 0.000839 * t + 0.0002261 * t2 - 0.00000845 * t3 - 0.000000081 * t * t3;
    } else {
        deltat = -0.000278 + 0.000265 * t + 0.000262 * t2;
    }
    let jd_new = jd1 + c1 - deltat;
    (jd_new + 0.5 + time_zone / 24.0).floor() as i32
}

fn get_sun_longitude(jdn: f64, time_zone: f64) -> i32 {
    let t = (jdn - 2451545.5 - time_zone / 24.0) / 36525.0; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    let t2 = t * t;
    let dr = std::f64::consts::PI / 180.0; // degree to radian
    let m = 357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2; // mean anomaly, degree
    let l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2; // mean longitude, degree
    let dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * (dr * m).sin();
    let dl = dl + (0.019993 - 0.000101 * t) * (dr * 2.0 * m).sin() + 0.000290 * (dr * 3.0 * m).sin();
    let l = l0 + dl; // true longitude, degree
    let l = l * dr;
    let l = l - std::f64::consts::PI * 2.0 * (l / (std::f64::consts::PI * 2.0)).floor(); // Normalize to (0, 2*PI)
    (l / std::f64::consts::PI * 6.0).floor() as i32
}

fn get_lunar_month11(yy: i32, time_zone: f64) -> i32 {
    let off = jd_from_date(31, 12, yy) - 2415021;
    let k = off / 29.530588853;
    let nm = get_new_moon_day(k.floor(), time_zone);
    let sun_long = get_sun_longitude(nm as f64, time_zone); // sun longitude at local midnight
    if sun_long >= 9.0 {
        get_new_moon_day(k.floor() - 1, time_zone)
    } else {
        nm
    }
}

fn get_leap_month_offset(a11: f64, time_zone: f64) -> i32 {
    let k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    let mut last = 0.0;
    let mut i = 1; // We start with the month following lunar month 11
    let mut arc = get_sun_longitude(get_new_moon_day(k + i, time_zone), time_zone);
    while arc != last && i < 14 {
        last = arc;
        i += 1;
        arc = get_sun_longitude(get_new_moon_day(k + i, time_zone), time_zone);
    }
    i - 1
}

fn get_can_chi_year(year: i32) -> String {
    format!("{} {}", THIEN_CAN_LIST[(year + 6) % 10], DIA_CHI_LIST[(year + 8) % 12])
}

fn get_can_chi_date_by_jd(jd: i32) -> String {
    let can = THIEN_CAN_LIST[(jd + 9) % 10];
    let chi = DIA_CHI_LIST[(jd + 1) % 12];
    format!("{} {}", can, chi)
}

fn get_can_chi_month(lunar_month: i32, lunar_year: i32) -> String {
    let can = THIEN_CAN_LIST[(lunar_year * 12 + lunar_month + 3) % 10];
    let chi = DIA_CHI_LIST[(lunar_month + 1) % 12];
    format!("{} {}", can, chi)
}

fn calculate_lich_lap_xuan(year: i32) -> DateTime<Utc> {
    let base_year = 1900;
    let base_date = NaiveDate::from_ymd(base_year, 2, 4).and_hms(0, 0, 0); // Lập Xuân của năm 1900 là 4 tháng 2
    let days_per_year = 365.2422; // Số ngày trung bình trong năm theo quỹ đạo Trái Đất

    let difference_in_years = year - base_year;
    let total_days_passed = difference_in_years as f64 * days_per_year;

    let lap_xuan_date = base_date.add_days(total_days_passed as i64);

    DateTime::from_utc(lap_xuan_date, Utc)
}

fn tiet_khi_index_to_dia_chi_month_index(index: usize) -> usize {
    if index >= TIET_KHI_LIST.len() {
        panic!("index out of range");
    }

    ((index + 2) / 2) + 1
}

fn calculate_tiet_khi(input_date: DateTime<Utc>) -> (String, String, String) {
    let year = input_date.year();
    let lich_lap_xuan = calculate_lich_lap_xuan(year);

    let days_since_lap_xuan = (input_date - lich_lap_xuan).num_days() as f64;

    let tiet_khi_index = (days_since_lap_xuan / 15.2184) as i32;
    let real_tiet_khi_index = if tiet_khi_index < 0 {
        TIET_KHI_LIST.len() as i32 + tiet_khi_index
    } else if tiet_khi_index >= TIET_KHI_LIST.len() as i32 - 1 {
        tiet_khi_index % TIET_KHI_LIST.len() as i32
    } else {
        tiet_khi_index
    };

    let tiet_khi = TIET_KHI_LIST[real_tiet_khi_index as usize].to_string();

    let dia_chi_month_index = tiet_khi_index_to_dia_chi_month_index(real_tiet_khi_index as usize);
    let virtual_lunar_month = dia_chi_month_index - 1;
    let virtual_lunar_year = if input_date < lich_lap_xuan {
        year - 1
    } else {
        year
    };

    let can_chi_year = get_can_chi_year(virtual_lunar_year);
    let can_chi_month = get_can_chi_month(virtual_lunar_month, virtual_lunar_year);

    (tiet_khi, can_chi_year, can_chi_month)
}

fn calculate_xung_khac_dia_chi(dia_chi_index: usize) -> usize {
    ((dia_chi_index + 1 + 6) % 12) - 1
}

fn calculate_pha_date(jd_date: usize, lunar_month: usize, year: usize) -> (bool, bool) {
    let is_nguyet_pha = calculate_xung_khac_dia_chi((jd_date + 1) % 12) == (lunar_month + 1) % 12;
    let is_tue_pha = calculate_xung_khac_dia_chi((jd_date + 1) % 12) == (year + 8) % 12;

    (is_nguyet_pha, is_tue_pha)
}

fn convert_solar2_lunar(dd: i32, mm: i32, yy: i32, time_zone: f64) -> (
    i32,
    i32,
    i32,
    i32,
    String,
    String,
    String,
    bool,
    bool,
) {
    let mut day_number = jd_from_date(dd, mm, yy);
    let k = (day_number - 2415021.076998695) / 29.530588853;
    let mut month_start = get_new_moon_day(k as i32 + 1, time_zone);
    if month_start > day_number {
        month_start = get_new_moon_day(k as i32, time_zone);
    }
    let a11 = get_lunar_month11(yy, time_zone);
    let b11 = a11;
    let mut lunar_year = if a11 >= month_start {
        yy
    } else {
        yy + 1
    };
    let a11 = if a11 >= month_start {
        get_lunar_month11(yy - 1, time_zone)
    } else {
        a11
    };
    let b11 = if a11 >= month_start {
        b11
    } else {
        get_lunar_month11(yy + 1, time_zone)
    };
    let lunar_day = day_number - month_start + 1;
    let diff = (month_start - a11) / 29;
    let mut lunar_leap = 0;
    let mut lunar_month = diff + 11;
    if b11 - a11 > 365.0 {
        let leap_month_diff = get_leap_month_offset(a11, time_zone);
        if diff >= leap_month_diff {
            lunar_month = diff + 10;
            if diff == leap_month_diff {
                lunar_leap = 1;
            }
        }
    }
    if lunar_month > 12 {
        lunar_month -= 12;
    }
    if lunar_month >= 11 && diff < 4 {
        lunar_year -= 1;
    }
    let can_chi_date = get_can_chi_date_by_jd(day_number);
    let can_chi_month = get_can_chi_month(lunar_month, lunar_year);
    let can_chi_year = get_can_chi_year(lunar_year);
    let is_pha_date = calculate_pha_date(day_number, lunar_month, lunar_year);

    (
        lunar_day,
        lunar_month,
        lunar_year,
        lunar_leap,
        can_chi_date,
        can_chi_month,
        can_chi_year,
        is_pha_date.0,
        is_pha_date.1,
    )
}

fn convert_lunar2_solar(
    lunar_day: i32,
    lunar_month: i32,
    lunar_year: i32,
    lunar_leap: i32,
    time_zone: f64,
) -> (i32, i32, i32) {
    let mut a11;
    let mut b11;
    let mut off;
    let mut leap_off;
    let mut leap_month;
    let mut month_start;

    if lunar_month < 11 {
        a11 = get_lunar_month11(lunar_year - 1, time_zone);
        b11 = get_lunar_month11(lunar_year, time_zone);
    } else {
        a11 = get_lunar_month11(lunar_year, time_zone);
        b11 = get_lunar_month11(lunar_year + 1, time_zone);
    }

    off = lunar_month - 11;
    if off < 0 {
        off += 12;
    }

    if b11 - a11 > 365.0 {
        leap_off = get_leap_month_offset(a11, time_zone);
        leap_month = leap_off - 2;
        if leap_month < 0 {
            leap_month += 12;
        }
        if lunar_leap != 0 && lunar_month != leap_month {
            return (0, 0, 0);
        } else if lunar_leap != 0 || off >= leap_off {
            off += 1;
        }
    }

    let k = (a11 - 2415021.076998695) / 29.530588853;
    month_start = get_new_moon_day(k as i32 + off as i32, time_zone);

    jd_to_date(month_start + lunar_day - 1)
}
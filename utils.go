package vietnameseyinyangcalendarutils

import (
	"fmt"
	"math"
	"time"
)

var THIEN_CAN_LIST = []string{"Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"}
var DIA_CHI_LIST = []string{"Tí", "Sửu", "Dần", "Mão", "Thìn", "Tị", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"}
var TIET_KHI_LIST = []string{
	"Lập Xuân", "Vũ Thủy", "Kinh Trập", "Xuân Phân",
	"Thanh Minh", "Cốc Vũ", "Lập Hạ", "Tiểu Mãn",
	"Mang Chủng", "Hạ Chí", "Tiểu Thử", "Đại Thử",
	"Lập Thu", "Xử Thử", "Bạch Lộ", "Thu Phân",
	"Hàn Lộ", "Sương Giáng", "Lập Đông", "Tiểu Tuyết",
	"Đại Tuyết", "Đông Chí", "Tiểu Hàn", "Đại Hàn",
}

func jdFromDate(dd, mm, yy int) int {
	a := int(math.Floor(float64((14 - mm) / 12)))
	y := yy + 4800 - a
	m := mm + 12*a - 3
	jd := dd + int(math.Floor(float64((153*m+2)/5))) + 365*y + int(math.Floor(float64(y/4))) - int(math.Floor(float64(y/100))) + int(math.Floor(float64(y/400))) - 32045
	if jd < 2299161 {
		jd = dd + int(math.Floor(float64((153*m+2)/5))) + 365*y + int(math.Floor(float64(y/4))) - 32083
	}
	return jd
}

func jdToDate(jd int) (int, int, int) {
	var a, b, c, d, e, m, day, month, year int
	if jd > 2299160 { // After 5/10/1582, Gregorian calendar
		a = jd + 32044
		b = int(math.Floor(float64((4*a + 3) / 146097)))
		c = a - int(math.Floor(float64((b*146097)/4)))
	} else {
		b = 0
		c = jd + 32082
	}
	d = int(math.Floor(float64((4*c + 3) / 1461)))
	e = c - int(math.Floor(float64((1461*d)/4)))
	m = int(math.Floor(float64((5*e + 2) / 153)))
	day = e - int(math.Floor(float64((153*m+2)/5))) + 1
	month = m + 3 - 12*int(math.Floor(float64(m/10)))
	year = b*100 + d - 4800 + int(math.Floor(float64(m/10)))
	return day, month, year
}

func getNewMoonDay(k, timeZone int) int {
	var T, T2, T3, dr, Jd1, M, Mpr, F, C1, deltat, JdNew float64
	T = float64(k) / 1236.85 // Time in Julian centuries from 1900 January 0.5
	T2 = T * T
	T3 = T2 * T
	dr = math.Pi / 180
	Jd1 = 2415020.75933 + 29.53058868*float64(k) + 0.0001178*T2 - 0.000000155*T3
	Jd1 = Jd1 + 0.00033*math.Sin((166.56+132.87*T-0.009173*T2)*dr)          // Mean new moon
	M = 359.2242 + 29.10535608*float64(k) - 0.0000333*T2 - 0.00000347*T3    // Sun's mean anomaly
	Mpr = 306.0253 + 385.81691806*float64(k) + 0.0107306*T2 + 0.00001236*T3 // Moon's mean anomaly
	F = 21.2964 + 390.67050646*float64(k) - 0.0016528*T2 - 0.00000239*T3    // Moon's argument of latitude
	C1 = (0.1734-0.000393*T)*math.Sin(M*dr) + 0.0021*math.Sin(2*dr*M)
	C1 = C1 - 0.4068*math.Sin(Mpr*dr) + 0.0161*math.Sin(dr*2*Mpr)
	C1 = C1 - 0.0004*math.Sin(dr*3*Mpr)
	C1 = C1 + 0.0104*math.Sin(dr*2*F) - 0.0051*math.Sin(dr*(M+Mpr))
	C1 = C1 - 0.0074*math.Sin(dr*(M-Mpr)) + 0.0004*math.Sin(dr*(2*F+M))
	C1 = C1 - 0.0004*math.Sin(dr*(2*F-M)) - 0.0006*math.Sin(dr*(2*F+Mpr))
	C1 = C1 + 0.0010*math.Sin(dr*(2*F-Mpr)) + 0.0005*math.Sin(dr*(2*Mpr+M))
	if T < -11 {
		deltat = 0.001 + 0.000839*T + 0.0002261*T2 - 0.00000845*T3 - 0.000000081*T*T3
	} else {
		deltat = -0.000278 + 0.000265*T + 0.000262*T2
	}
	JdNew = Jd1 + C1 - deltat
	return int(math.Floor(JdNew + 0.5 + float64(timeZone)/24))
}

func getSunLongitude(jdn, timeZone int) int {
	var T, T2, dr, M, L0, DL, L float64
	T = (float64(jdn) - 2451545.5 - float64(timeZone)/24) / 36525 // Time in Julian centuries from 2000-01-01 12:00:00 GMT
	T2 = T * T
	dr = math.Pi / 180                                             // degree to radian
	M = 357.52910 + 35999.05030*T - 0.0001559*T2 - 0.00000048*T*T2 // mean anomaly, degree
	L0 = 280.46645 + 36000.76983*T + 0.0003032*T2                  // mean longitude, degree
	DL = (1.914600 - 0.004817*T - 0.000014*T2) * math.Sin(dr*M)
	DL = DL + (0.019993-0.000101*T)*math.Sin(dr*2*M) + 0.000290*math.Sin(dr*3*M)
	L = L0 + DL // true longitude, degree
	L = L * dr
	L = L - math.Pi*2*(math.Floor(L/(math.Pi*2))) // Normalize to (0, 2*PI)
	return int(math.Floor(L / math.Pi * 6))
}

func getLunarMonth11(yy, timeZone int) int {
	var k, off, nm, sunLong int
	off = jdFromDate(31, 12, yy) - 2415021
	k = int(math.Floor(float64(off) / 29.530588853))
	nm = getNewMoonDay(k, timeZone)
	sunLong = getSunLongitude(nm, timeZone) // sun longitude at local midnight
	if sunLong >= 9 {
		nm = getNewMoonDay(k-1, timeZone)
	}
	return nm
}

func getLeapMonthOffset(a11, timeZone int) int {
	var k, last, arc, i int
	k = int(math.Floor(float64((float64(a11)-2415021.076998695)/29.530588853 + 0.5)))
	last = 0
	i = 1 // We start with the month following lunar month 11
	arc = getSunLongitude(getNewMoonDay(k+i, timeZone), timeZone)
	for arc != last && i < 14 {
		last = arc
		i++
		arc = getSunLongitude(getNewMoonDay(k+i, timeZone), timeZone)
	}
	return i - 1
}

func convertSolar2Lunar(dd, mm, yy, timeZone int) (int, int, int, int, string, string, string) {
	var k, dayNumber, monthStart, a11, b11, lunarDay, lunarMonth, lunarYear, lunarLeap, diff int
	dayNumber = jdFromDate(dd, mm, yy)
	k = int(math.Floor(float64((float64(dayNumber) - 2415021.076998695) / 29.530588853)))
	monthStart = getNewMoonDay(k+1, timeZone)
	if monthStart > dayNumber {
		monthStart = getNewMoonDay(k, timeZone)
	}
	a11 = getLunarMonth11(yy, timeZone)
	b11 = a11
	if a11 >= monthStart {
		lunarYear = yy
		a11 = getLunarMonth11(yy-1, timeZone)
	} else {
		lunarYear = yy + 1
		b11 = getLunarMonth11(yy+1, timeZone)
	}
	lunarDay = dayNumber - monthStart + 1
	diff = int(math.Floor(float64((monthStart - a11) / 29)))
	lunarLeap = 0
	lunarMonth = diff + 11
	if b11-a11 > 365 {
		leapMonthDiff := getLeapMonthOffset(a11, timeZone)
		if diff >= leapMonthDiff {
			lunarMonth = diff + 10
			if diff == leapMonthDiff {
				lunarLeap = 1
			}
		}
	}
	if lunarMonth > 12 {
		lunarMonth = lunarMonth - 12
	}
	if lunarMonth >= 11 && diff < 4 {
		lunarYear -= 1
	}
	canChiDate := getCanChiDateByJd(dayNumber)
	canChiMonth := getCanChiMonth(lunarMonth, lunarYear)
	canChiYear := getCanChiYear(lunarYear)
	return lunarDay, lunarMonth, lunarYear, lunarLeap, canChiDate, canChiMonth, canChiYear
}

func convertLunar2Solar(lunarDay, lunarMonth, lunarYear, lunarLeap, timeZone int) (int, int, int) {
	var k, a11, b11, off, leapMonth, monthStart int
	if lunarMonth < 11 {
		a11 = getLunarMonth11(lunarYear-1, timeZone)
		b11 = getLunarMonth11(lunarYear, timeZone)
	} else {
		a11 = getLunarMonth11(lunarYear, timeZone)
		b11 = getLunarMonth11(lunarYear+1, timeZone)
	}
	off = lunarMonth - 11
	if off < 0 {
		off += 12
	}
	if b11-a11 > 365 {
		leapOff := getLeapMonthOffset(a11, timeZone)
		leapMonth = leapOff - 2
		if leapMonth < 0 {
			leapMonth += 12
		}
		if lunarLeap != 0 && lunarMonth != leapMonth {
			return 0, 0, 0
		} else if lunarLeap != 0 || off >= leapOff {
			off += 1
		}
	}
	k = int(math.Floor(0.5 + (float64(a11)-2415021.076998695)/29.530588853))
	monthStart = getNewMoonDay(k+off, timeZone)
	return jdToDate(monthStart + lunarDay - 1)
}

func getCanChiYear(year int) string {
	return fmt.Sprintf("%s %s", THIEN_CAN_LIST[(year+6)%10], DIA_CHI_LIST[(year+8)%12])
}

func getCanChiDateByJd(jd int) string {
	can := THIEN_CAN_LIST[(jd+9)%10]
	chi := DIA_CHI_LIST[(jd+1)%12]
	return fmt.Sprintf("%s %s", can, chi)
}

func getCanChiMonth(lunarMonth, lunarYear int) string {
	can := THIEN_CAN_LIST[(lunarYear*12+lunarMonth+3)%10]
	chi := DIA_CHI_LIST[(lunarMonth+1)%12]
	return fmt.Sprintf("%s %s", can, chi)
}

func calculateLichLapXuan(year int) time.Time {
	// Dữ liệu cơ bản:
	baseYear := 1900
	baseDate := time.Date(baseYear, 2, 4, 0, 0, 0, 0, time.UTC) // Lập Xuân của năm 1900 là 4 tháng 2
	daysPerYear := 365.2422                                     // Số ngày trung bình trong năm theo quỹ đạo Trái Đất

	// Tính toán số năm cách từ năm 1900
	differenceInYears := year - baseYear

	// Tính tổng số ngày đã qua kể từ năm 1900
	totalDaysPassed := float64(differenceInYears) * daysPerYear

	// Tạo đối tượng ngày mới dựa trên số ngày đã qua
	lapXuanDate := baseDate.AddDate(0, 0, int(totalDaysPassed))

	// Trả về ngày Lập Xuân (kết quả là một đối tượng Time)
	return lapXuanDate
}

func tietKhiIndexToDiaChiMonthIndex(index int) (int, error) {
	if index < 0 {
		return 0, fmt.Errorf("index < 0")
	}

	if index >= len(TIET_KHI_LIST) {
		return 0, fmt.Errorf("index should be <= 23")
	}

	return ((index + 2) / 2) + 1, nil
}

func calculateTietKhi(inputDate time.Time) (map[string]string, error) {
	year := inputDate.Year()
	lichLapXuan := calculateLichLapXuan(year)

	// Tính số ngày đã trôi qua kể từ ngày Lập Xuân
	daysSinceLapXuan := int(inputDate.Sub(lichLapXuan).Hours() / 24)

	// Xác định tiết khí dựa trên số ngày đã trôi qua
	tietKhiIndex := daysSinceLapXuan / 15
	realTietKhiIndex := tietKhiIndex
	if realTietKhiIndex < 0 {
		realTietKhiIndex = len(TIET_KHI_LIST) + tietKhiIndex
	} else if tietKhiIndex >= len(TIET_KHI_LIST)-1 {
		realTietKhiIndex = tietKhiIndex % len(TIET_KHI_LIST)
	}

	tietKhi := TIET_KHI_LIST[realTietKhiIndex]

	diaChiMonthIndex, err := tietKhiIndexToDiaChiMonthIndex(realTietKhiIndex)
	if err != nil {
		return nil, err
	}
	virtualLunarMonth := diaChiMonthIndex - 1
	virtualLunarYear := year
	if inputDate.Before(lichLapXuan) {
		virtualLunarYear -= 1
	}
	canChiYear := getCanChiYear(virtualLunarYear)
	canChiMonth := getCanChiMonth(virtualLunarMonth, virtualLunarYear)

	return map[string]string{
		"tietKhi":     tietKhi,
		"canChiYear":  canChiYear,
		"canChiMonth": canChiMonth,
	}, nil
}

// func main() {
// 	today := time.Now()
// 	tietKhi, _ := calculateTietKhi(today)
// 	fmt.Println(tietKhi)
// }

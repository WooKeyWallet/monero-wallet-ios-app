//
//  Date + Ext.swift


import Foundation

extension Date {
    
    static func from(_ string: String, formatt: String) -> Date? {
        let fmt = DateFormatter.init()
        fmt.dateFormat = formatt
        return fmt.date(from: string)
    }
    
    func toString(_ formatter:String = "yyyy-MM-dd")->String {
        let fmt = DateFormatter.init()
        fmt.dateFormat = formatter
        return fmt.string(from: self)
    }
    
    func weekDay() -> String {
        let weekDays = [
        "",
        LocalizedString(key: "Sunday", comment: "周日"),
        LocalizedString(key: "Monday", comment: "周一"),
        LocalizedString(key: "Tuesday", comment: "周二"),
        LocalizedString(key: "Wednesday", comment: "周三"),
        LocalizedString(key: "Thursday", comment: "周四"),
        LocalizedString(key: "Friday", comment: "周五"),
        LocalizedString(key: "Saturday", comment: "周六"),
        "",
        ]
        dPrint(TimeZone.current.identifier)
        var calendar = Calendar.init(identifier: .chinese)
        let timeZone = TimeZone.init(identifier: "Asia/Shanghai")!
        
        calendar.timeZone = timeZone
        let theComponents = calendar.component(Calendar.Component.weekday, from: self)
        return weekDays[theComponents]
    }
}


/// date to block height

extension Date {
    
    static let blockheight: [String: UInt64] = [
        "2014-05-01": 18844,
        "2014-06-01": 65406,
        "2014-07-01": 108882,
        "2014-08-01": 153594,
        "2014-09-01": 198072,
        "2014-10-01": 241088,
        "2014-11-01": 285305,
        "2014-12-01": 328069,
        "2015-01-01": 372369,
        "2015-02-01": 416505,
        "2015-03-01": 456631,
        "2015-04-01": 501084,
        "2015-05-01": 543973,
        "2015-06-01": 588326,
        "2015-07-01": 631187,
        "2015-08-01": 675484,
        "2015-09-01": 719725,
        "2015-10-01": 762463,
        "2015-11-01": 806528,
        "2015-12-01": 849041,
        "2016-01-01": 892866,
        "2016-02-01": 936736,
        "2016-03-01": 977691,
        "2016-04-01": 1015848,
        "2016-05-01": 1037417,
        "2016-06-01": 1059651,
        "2016-07-01": 1081269,
        "2016-08-01": 1103630,
        "2016-09-01": 1125983,
        "2016-10-01": 1147617,
        "2016-11-01": 1169779,
        "2016-12-01": 1191402,
        "2017-01-01": 1213861,
        "2017-02-01": 1236197,
        "2017-03-01": 1256358,
        "2017-04-01": 1278622,
        "2017-05-01": 1300239,
        "2017-06-01": 1322564,
        "2017-07-01": 1344225,
        "2017-08-01": 1366664,
        "2017-09-01": 1389113,
        "2017-10-01": 1410738,
        "2017-11-01": 1433039,
        "2017-12-01": 1454639,
        "2018-01-01": 1477201,
        "2018-02-01": 1499599,
        "2018-03-01": 1519796,
        "2018-04-01": 1542067,
        "2018-05-01": 1562861,
        "2018-06-01": 1585135,
        "2018-07-01": 1606715,
        "2018-08-01": 1629017,
        "2018-09-01": 1651347,
        "2018-10-01": 1673031,
        "2018-11-01": 1695128,
        "2018-12-01": 1716687,
        "2019-01-01": 1738923,
        "2019-02-01": 1761435,
        "2019-03-01": 1781681,
        "2019-04-01": 1803081,
    ]
    
    func getBlockHeight() -> UInt64 {
        let year = Int(self.toString("yyyy")) ?? 0
        let mon = Int(self.toString("MM")) ?? 0
        
        guard year >= 2014 else {
            return 0
        }
        if year == 2014, mon < 5 {
            return 0
        }
        if let height = Date.blockheight[self.toString("yyyy-MM-01")] {
            return height
        }
        return Date.blockheight.map({ return $0.value }).last ?? 0
    }
}

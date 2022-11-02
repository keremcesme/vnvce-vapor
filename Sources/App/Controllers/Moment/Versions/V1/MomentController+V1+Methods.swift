//
//  File.swift
//  
//
//  Created by Kerem Cesme on 11.10.2022.
//

import Fluent
import Vapor

// MARK: MomentController V1 - Methods -
extension MomentController.V1 {
    
    func uploadMomentTest(_ req: Request) async throws -> HTTPStatus {
        let id = UUID(uuidString: "d4c2c1e2-c232-4df9-8a2e-dec5bdac916e")
        
        guard let userID = try await User.find(id, on: req.db)?.requireID() else {
            throw Abort(.notFound)
        }
        
        let moment = Moment(ownerID: userID, mediaType: .image, name: "name", url: "url")
        
        try await moment.create(on: req.db)
        
        return .ok
    }
    
    func uploadMomentHandler(_ req: Request) async throws -> Response<Moment.V1> {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let payload = try req.content.decode(UploadMomentPayload.V1.self)
        
        let moment = Moment(ownerID: userID,
                            mediaType: payload.type,
                            name: payload.name,
                            url: payload.url,
                            thumbnailURL: payload.thumbnailURL)
        
        try await moment.create(on: req.db)
        
        return Response(result: try moment.convertMoment(), message: "Upload Finished")
    }
    
    func fetchMomentsTest(_ req: Request) async throws -> HTTPStatus {
        let id = UUID(uuidString: "d4c2c1e2-c232-4df9-8a2e-dec5bdac916e")!
        
        let oneMonthAgo = Date().addingTimeInterval(-2592000)
        
        let moments = try await Moment.query(on: req.db)
            .filter(\.$createdAt > oneMonthAgo)
            .sort(\.$createdAt, .descending)
            .all()
            .convertMoments()
//            .sortAndGroup()
        
//        let convertedMoments = moments.testConverts()
//
//        // SOLUTION 1
//        var temp = [String : [Moment.V1]]()
//
//        convertedMoments.forEach {
//            let time = "\($0.hour):\($0.minute)"
//            var momentsArray = temp[time] ?? []
//            momentsArray.append($0)
//            temp[time] = momentsArray
//        }
//
//
//        let sortedMoments: [[Moment.V1]] = temp.sorted(by: { $0.key < $1.key }).map(\.value)
//        let sortedMoments2: [[Moment.V1]] = temp.sorted(by: { $0.key < $1.key}).map({ $0.value })
//
//        let sortedMoments3: [[Moment.V1]] = Dictionary(
//            grouping: convertedMoments,
//            by: { "\($0.hour):\($0.minute)"})
//            .sorted(by: { $0.key < $1.key })
//            .map { $0.value }
//
//
//        let groupedData: [[Moment.V1]] = temp.map { $0.value }

        
//        for moment in moments {
//            print("~~~~~~~~~~~~~~~")
//            for i in moment {
////                print("     \(i.hour):\(i.minute)")
//                print("     \(i.day)")
//            }
//        }
        
        // SOLUTION 2
//        let groupedItems = Dictionary(grouping: convertedMoments) { (moment) in
//
//            return moment.minute
//
//        }
//
//        let values = groupedItems.values
//        let sortedKeys = Array(groupedItems.keys).sorted(by: <)
//
//        let sortedItems = groupedItems.sorted(by: { $0.key < $1.key })
//
//
//        for item in sortedItems {
//            print("~~~~~~~~~~~~~~~")
//            print(item)
//        }
        
//        for item in values {
//            print("~~~~~~~~~~~~~~~")
//            for i in item {
//                print("     \(i.hour):\(i.minute)")
//            }
//        }
        
        
//        let filteredMoments = moments.filter { m in
//
//        }
        
//        var groupedMoments = [[Moment]]()
//
//        for fetchedMoment in moments {
//
//            let date = fetchedMoment.createdAt!
//            let calendar = Calendar.current.dateComponents([.hour, .minute], from: date)
//            let hour = calendar.hour!
//            let minute = calendar.minute!
//
//            let time = "\(hour):\(minute)"
//
//            if groupedMoments.isEmpty {
//                groupedMoments.append([fetchedMoment])
//            } else {
//                for moments in groupedMoments.enumerated() {
//                    let moment = moments.element.first!
//                    let date = moment.createdAt!
//                    let calendar = Calendar.current.dateComponents([.hour, .minute], from: date)
//                    let hour = calendar.hour!
//                    let minute = calendar.minute!
//
//                    if time == "\(hour):\(minute)" {
//                        groupedMoments[moments.offset].append(fetchedMoment)
//                    } else {
//                        groupedMoments.append([fetchedMoment])
//                    }
//
//                }
//            }
//
//        }
//
//        for moments in groupedMoments {
//            for moment in moments {
//                print("~~~~~~~~~~~~~~~")
//                let date = moment.createdAt!
//                let calendar = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
//                let hour = calendar.hour!
//                let minute = calendar.minute!
//                let day = calendar.day!
//                let month = calendar.month!
//                let year = calendar.year!
//                print("DAY: \(day), MONTH: \(month), TIME: \(hour):\(minute)")
//            }
//        }
        
//        for moment in moments {
//            print("~~~~~~~~~~~~~~~")
//            let date = moment.createdAt!
//            let calendar = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
//
//            let hour = calendar.hour!
//            let minute = calendar.minute!
//            let day = calendar.day!
//            let month = calendar.month!
//            let year = calendar.year!
//
//            print("DAY: \(day), MONTH: \(month), TIME: \(hour):\(minute)")
//        }
        
        return .ok
    }
    
    func fetchMomentsHandler(_ req: Request) async throws -> Response<[Moment.V1]> {
        let usrID = try req.auth.require(User.self).requireID()
        let payload = try req.content.decode(MomentsPayload.V1.self)
        let userID = returnMomentsOwnerID(usrID, payload)
        let oneMonthAgo = Date().addingTimeInterval(-2592000)
        
        let moments = try await Moment.query(on: req.db)
            .filter(\.$owner.$id == userID)
            .filter(\.$createdAt > oneMonthAgo)
            .sort(\.$createdAt, .descending)
            .all()
            .convertMoments()
        
        return Response(result: moments, message: "Success")
            
    }
    
//    func uploadMomentHandler(_ req: Request) async throws -> Response<MomentDay.V1> {
//        let user = try req.auth.require(User.self)
//        let userID = try user.requireID()
//        let payload = try req.content.decode(UploadMomentPayload.V1.self)
//
//        let currentDate = try getCurrentDate()
//
//        if let momentDay = try await MomentDay.query(on: req.db)
//            .filter(\.$owner.$id == userID)
//            .filter(\.$day == currentDate.day)
//            .filter(\.$month == currentDate.month)
//            .filter(\.$year == currentDate.year)
//            .first() {
//            let momentDay: MomentDay.V1 = try await req.db.transaction{
//                let dayID = try momentDay.requireID()
//                let moment = Moment(ownerID: userID, dayID: dayID)
//                try await momentDay.$moments.create(moment, on: $0)
//                let momentID = try moment.requireID()
//                let media = MomentMedia(momentID: momentID, mediaType: payload.type, name: payload.name, url: payload.url)
//                try await moment.$media.create(media, on: $0)
//                try await momentDay.$moments.load(on: $0)
//                return try await momentDay.convert(owner: user.convertToPublic($0), $0)
//            }
//            return Response(result: momentDay, message: "Created [1]")
//        } else {
//            let momentDay = MomentDay(ownerID: userID, day: currentDate.day, month: currentDate.month, year: currentDate.year)
//            let momentDays: MomentDay.V1 = try await req.db.transaction{
//                try await momentDay.create(on: $0)
//                let dayID = try momentDay.requireID()
//                let moment = Moment(ownerID: userID, dayID: dayID)
//                try await momentDay.$moments.create(moment, on: $0)
//                let momentID = try moment.requireID()
//                let media = MomentMedia(momentID: momentID, mediaType: payload.type, name: payload.name, url: payload.url)
//                try await moment.$media.create(media, on: $0)
//                try await momentDay.$moments.load(on: $0)
//                return try await momentDay.convert(owner: user.convertToPublic($0), $0)
//            }
//            return Response(result: momentDays, message: "Created [2]")
//        }
//    }
//
//    func uploadMomentHandler2(_ req: Request) async throws -> HTTPStatus {
//
//        let id = UUID(uuidString: "d4c2c1e2-c232-4df9-8a2e-dec5bdac916e")
//
//        guard let userID = try await User.find(id, on: req.db)?.requireID() else {
//            throw Abort(.notFound)
//        }
//
//        guard let day = Int(req.parameters.get("day")!),
//              let month = try Int(req.parameters.get("month")!)?.convertToMonth() else {
//            throw Abort(.notFound)
//        }
//
//        let year = 2022
//
//        let date = Date()
//        let calendar = Calendar.current.dateComponents([.day, .month, .year], from: date)
//        //        print("Timezone: \(calendar.timeZone!)")
//        //        print("Minute: \(calendar.minute!)")
//        //        print("Hour: \(calendar.hour!)")
//        //        print("Day: \(calendar.day!)")
//        //        print("Month: \(calendar.month!)")
//        //        print("Year: \(calendar.year!)")
//        //
//        //        print("Date: \(Calendar.current.date(from: calendar)!)")
//        //        print("Timestamp: \(Calendar.current.date(from: calendar)!.timeIntervalSince1970)")
//        //        guard let day = calendar.day,
//        //              let month = try calendar.month?.convertToMonth(),
//        //              let year = calendar.year else {
//        //            throw Abort(.notFound)
//        //        }
//
//        if let momentDay = try await MomentDay.query(on: req.db)
//            .filter(\.$owner.$id == userID)
//            .filter(\.$day == day)
//            .filter(\.$month == month)
//            .filter(\.$year == year)
//            .first() {
//            try await req.db.transaction{
//                let dayID = try momentDay.requireID()
//                let moment = Moment(ownerID: userID, dayID: dayID)
//                try await momentDay.$moments.create(moment, on: $0)
//                let momentID = try moment.requireID()
//                let media = MomentMedia(momentID: momentID, mediaType: .image, name: "name", url: "url")
//                try await moment.$media.create(media, on: $0)
//                print("Created [1]")
//            }
//        } else {
//            let momentDay = MomentDay(ownerID: userID, day: day, month: month, year: year)
//            try await req.db.transaction{
//                try await momentDay.create(on: $0)
//                let dayID = try momentDay.requireID()
//                let moment = Moment(ownerID: userID, dayID: dayID)
//                try await momentDay.$moments.create(moment, on: $0)
//                let momentID = try moment.requireID()
//                let media = MomentMedia(momentID: momentID, mediaType: .image, name: "name", url: "url")
//                try await moment.$media.create(media, on: $0)
//                print("Created [2]")
//            }
//        }
//
//        return .ok
//    }
//
//    func deleteAllHandler(_ req: Request) async throws -> HTTPStatus {
//        try await MomentDay.query(on: req.db).delete(force: true)
//        return .ok
//    }
//
//    //    func fetchMomentsHandler2(_ req: Request) async throws -> HTTPStatus {
//    //
//    //        let date = Date()
//    //        let calendar = Calendar.current.dateComponents([.day, .month, .year], from: date)
//    //
//    //        guard let day = calendar.day,
//    //              let month = calendar.month,
//    //              let year = calendar.year else {
//    //            throw Abort(.notFound)
//    //        }
//    //
//    //        let convertedMonth = try month.convertToMonth()
//    //
//    //        let previousMonth = try previousMonth(month)
//    //        let previousMonthLastDay = lastDay(ofMonth: previousMonth.0, year: year)
//    //
//    //        let momentDays = try await MomentDay.query(on: req.db)
//    //            .with(\.$moments)
//    //            .group(.or){ group in
//    //
//    //
//    //                group
//    //
//    //                    .group(.and) { group in
//    //                        group
//    //                            .filter(\.$month == convertedMonth)
//    //                            .filter(\.$day <= lastDay(ofMonth: month, year: year))
//    //                    }
//    //
//    //                    .group(.and) { group in
//    //                        group
//    //                            .filter(\.$month == previousMonth.1)
//    //                            .filter(\.$day == previousMonthLastDay)
//    //                    }
//    //
//    //
//    //
//    //            }
//    //            .sort(\.$createdAt, .descending)
//    //            .all()
//    //
//    //
//    //
//    //        print("-----------------------------")
//    //        print("LASY DAY OF THE MONTH: \(lastDay(ofMonth: month, year: year))")
//    //
//    //
//    //        for momentDay in momentDays {
//    //
//    //            print("~~~~~~~~~~~~~~~")
//    //            print("DAY: \(momentDay.day), MONTH: \(momentDay.month)")
//    //            for moment in momentDay.moments.enumerated() {
//    //                print("     [\(moment.offset)] ID: \(try moment.element.requireID()), DATE: \(moment.element.createdAt!)")
//    //            }
//    //
//    //
//    //        }
//    //
//    //
//    //
//    //        return .ok
//    //    }

//    func fetchMomentsHandler(_ req: Request) async throws -> Response<[MomentDay.V1]> {
//        let usr = try req.auth.require(User.self)
//        let payload = try req.content.decode(MomentsPayload.V1.self)
//        let (user, userID) = try await returnMomentsOwner(user: usr, payload: payload, req.db)
//        let moments = try await momentsQueryBuilder(userID: userID, req.db).all()
//        let momentDays = try await moments.convertMomentDays(owner: user, req.db)
//
////        for momentDay in momentDays {
////
//            print("~~~~~~~~~~~~~~~")
//            print("DAY: \(momentDay.day), MONTH: \(momentDay.month)")
//            for moment in momentDay.moments.enumerated() {
//                print("     [\(moment.offset)], DATE: \(moment.element.createdAt)")
//            }
//        }
//
//
////        for day in momentDays {
////            print(day.moments.count)
////        }
//
//        return Response(result: momentDays, message: "SUCCESS")
//    }

//    func fetchMomentsHandler2(_ req: Request) async throws -> HTTPStatus {
//
//        let currentDate = try getCurrentDate()
//        let previousDate = try getPreviousDate(currentDate)
//
//        let moments = try await MomentDay.query(on: req.db)
//            .with(\.$moments)
//            .group(.or) {
//                $0
//                    .group(.and) {
//                        $0
//                            .filter(\.$day <= currentDate.lastDay)
//                            .filter(\.$month == currentDate.month)
//                            .filter(\.$year == currentDate.year)
//                    }
//                    .group(.and) {
//                        $0
//                            .filter(\.$day == previousDate.lastDay)
//                            .filter(\.$month == previousDate.month)
//                            .filter(\.$year == previousDate.year)
//                    }
//            }
//            .sort(\.$createdAt, .descending)
//            .all()
//
//        print("-----------------------------")
//        print("\(Date())")
//        print("-----------------------------")
//        print("LASY DAY OF THE MONTH: \(currentDate.lastDay)")
//
//
//        for momentDay in moments {
//
//            print("~~~~~~~~~~~~~~~")
//            print("DAY: \(momentDay.day), MONTH: \(momentDay.month)")
//            for moment in momentDay.moments.enumerated() {
//                print("     [\(moment.offset)] ID: \(try moment.element.requireID()), DATE: \(moment.element.createdAt!)")
//            }
//
//
//        }
//
//        return .ok
//    }
//
//    func previousMonth(_ currentMonth: Int) throws -> (Int, Month) {
//        if currentMonth == 1 {
//            return (12, try 12.convertToMonth())
//        } else {
//            let month = currentMonth - 1
//            return (month, try month.convertToMonth())
//        }
//    }
    
}

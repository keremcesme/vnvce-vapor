////
////  File.swift
////
////
////  Created by Kerem Cesme on 12.10.2022.
////
//
//import Fluent
//import Vapor
//import VNVCECore
//
//extension MomentController.V1 {
//    typealias CurrentDate = (day: Int, month: Month, year: Int, lastDay: Int)
//    typealias PreviousDate = (lastDay: Int, month: Month, year: Int)
//
////    func getCurrentDate() throws -> CurrentDate {
////        let date = Date()
////        let calendar = Calendar.current.dateComponents([.day, .month, .year], from: date)
////
////        guard let day = calendar.day,
////              let month = calendar.month,
////              let year = calendar.year
////        else {
////            throw Abort(.notFound)
////        }
////
//////        let month = 2
////
////        let lastDay = getLastDayOfTheMonth(ofMonth: month, year: year)
////
////        return (day: day, month: try month.convertToMonth(), year: year, lastDay: lastDay)
////    }
////
////    func getPreviousDate(_ currentDate: CurrentDate) throws -> PreviousDate {
////        if currentDate.month == .january {
////            let month: Month = .december
////            let year = currentDate.year - 1
////            let day = getLastDayOfTheMonth(ofMonth: month.convertToInt, year: year)
////
////            return (lastDay: day, month: month, year: year)
////        } else {
////            let monthInt = currentDate.month.convertToInt - 1
////            let month = try monthInt.convertToMonth()
////            let day = getLastDayOfTheMonth(ofMonth: monthInt, year: currentDate.year)
////
////            return (lastDay: day, month: month, year: currentDate.year)
////        }
////    }
////
////    func getLastDayOfTheMonth(ofMonth m: Int, year y: Int) -> Int {
////        let cal = Calendar.current
////        var comps = DateComponents(calendar: cal, year: y, month: m)
////        comps.setValue(m + 1, for: .month)
////        comps.setValue(0, for: .day)
////        let date = cal.date(from: comps)!
////        return cal.component(.day, from: date)
////    }
////
////    func momentsQueryBuilder(userID: User.IDValue, _ db: Database) throws -> QueryBuilder<MomentDay> {
////
////        let currentDate = try getCurrentDate()
////        let previousDate = try getPreviousDate(currentDate)
////
////        let query = MomentDay.query(on: db)
////            .with(\.$moments)
////            .filter(\.$owner.$id == userID)
////            .group(.or) {
////                $0
////                    .group(.and) {
////                        $0
////                            .filter(\.$day <= currentDate.lastDay)
////                            .filter(\.$month == currentDate.month)
////                            .filter(\.$year == currentDate.year)
////                    }
////                    .group(.and) {
////                        $0
////                            .filter(\.$day == previousDate.lastDay)
////                            .filter(\.$month == previousDate.month)
////                            .filter(\.$year == previousDate.year)
////                    }
////            }
////            .sort(\.$createdAt, .descending)
////
////
////        return query
////    }
////
////    public func returnMomentsOwner(user: User, payload: MomentsPayload.V1, _ db: Database) async throws -> (User.Public, User.IDValue) {
////        switch payload {
////        case .me:
////            return (try await user.convertToPublic(db), try user.requireID())
////        case let .user(userID):
////            guard let user = try await User.find(userID, on: db) else {
////                throw Abort(.notFound)
////            }
////            return (try await user.convertToPublic(db), userID)
////        }
////    }
//
//    public func returnMomentsOwnerID(_ userID: User.IDValue, _ payload: MomentsPayload.V1) -> User.IDValue {
//        switch payload {
//        case .me:
//            return userID
//        case let .user(userID):
//            return userID
//        }
//    }
//
//}

//: Playground - noun: a place where people can play

import PlaygroundSupport
import Foundation
import RealmSwift
import RxSwift

PlaygroundPage.current.needsIndefiniteExecution = true

class RealmString: Object {
  dynamic var string: String = ""
}

class RealmStringService {
  
  let realm: Realm
  let backgroundScheduler: SchedulerType
  
  init(scheduler: SchedulerType, realm: Realm) {
    self.realm = realm
    self.backgroundScheduler = scheduler
  }
  
  func getStringsFromRealm() -> Observable<[String]> {
    return
      Observable
        .just()
        .observeOn(backgroundScheduler)
        .map{ [unowned self] in
          return self.realm.objects(RealmString.self).map{ $0.string }
        }
        .observeOn(MainScheduler.instance)
    
  }
  
}

let realm = try! Realm(configuration: .init(inMemoryIdentifier: "testing"))

//Try changing these and you will see the realm::IncorrectThreadException

let scheduler = ConcurrentDispatchQueueScheduler(qos: .utility)
//let scheduler = MainScheduler.instance

try! realm.write {
  let sampleRealmString = RealmString()
  sampleRealmString.string = "Test"
  realm.add(sampleRealmString)
}

let disposeBag = DisposeBag()
let service = RealmStringService(scheduler: scheduler, realm: realm)
service
  .getStringsFromRealm()
  .subscribe(onNext:{ print($0) })
  .disposed(by: disposeBag)

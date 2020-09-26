import SwiftUI

struct ContentView: View {

    // @State: 뷰의 상태를 이어주기 위한 키워드
    // 값을 Binding으로 감싸줌으로써 값이 언제 바뀌었는지 알아내고 변경된 정보를 통해 뷰를 다시 그리는 데에 사용할 수 있게 함
    // self.$count -> Binding<Int>
    // 로컬에 한정되어 있기 때문에 화면을 벗어나면 상태가 유지되지 않음
//    @State var count: Int = 0

    // @ObservedObject: @State와 유사한 기능을 하는 키워드
    // 상태가 어느 위치에서 어떻게 작동해야하는지 SwiftUI 시스템에 알려줄 필요가 없음
    // 글로벌하게 상태를 저장할 수 있음
//    @ObservedObject var count: Int

    @ObservedObject var state: AppState

    // some: View 프로토콜에 맞는 어떠한 값을 반환한다는 뜻
    var body: some View {
        // NavigationView: NavigationLink(다른 화면으로 갈 수 있는 버튼)를 사용할 수 있게 됨
        NavigationView {
            // List: SwiftUI는 여러 요소가 나란히 있거나, 하나의 요소가 다른 하나의 위에 있을 경우만 뷰를 그리기 때문에
            // 버튼 두 개가 나란히 보일 수 있도록 List 키워드를 적어줌
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritePrimesView(favoritePrimes: self.$state.favoritePrimes,
                                                               activityFeed: self.$state.activityFeed)) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}

import Combine

// ObservableObject은 AnyObject 프로토콜을 상속 중
//struct AppState: ObservableObject {
class AppState: ObservableObject {
//    var count = 0 {
//        willSet {
//            self.objectWillChange.send()
//        }
//    }
    // @Published를 사용하면 objectWillChange를 사용하지 않아도 됨
    @Published var count = 0
    @Published var favoritePrimes: [Int] = []

    @Published var activityFeed: [Activity] = []
    @Published var loggedInUser: User? = nil

    struct Activity {
        let timestamp: Date
        let type: ActivityType

        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }

    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

// 상태 변화 코드 모음
extension AppState {

    func addFavoritePrime() {
        self.favoritePrimes.append(self.count)
        self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(self.count)))
    }

    func removeFavoritePrime(_ prime: Int) {
        self.favoritePrimes.removeAll(where: { $0 == prime })
        self.activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
    }

    func removeFavoritePrime() {
        self.removeFavoritePrime(self.count)
    }

    func removeFavoritePrimes(at indexSet: IndexSet) {
        for index in indexSet {
            self.removeFavoritePrime(self.favoritePrimes[index])
        }
    }
}

struct PrimeAlert: Identifiable {

  let prime: Int

  var id: Int { self.prime }
}

struct CounterView: View {

    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false

    var body: some View {
        VStack {
            HStack {
                // MARK: 애플리케이션 아키텍쳐 관점에서 봤을 때 해결해야 할 문제 4가지
                // MARK: 1. 변화하는 상태를 관리하는 방법
                // 문제점: 상태 변화 코드가 분산되어 있다
                // 해결방법: AppState를 extension 함으로써 상태 변화 코드를 하나로 모은다
                Button(action: { self.state.count -= 1 }) {
                    Text("-")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                    Text("+")
                }
            }
            Button(action: { self.isPrimeModalShown = true }) {
              Text("Is this prime?")
            }
            Button(action: self.nthPrimeButtonAction) {
              Text("What is the \(ordinal(self.state.count)) prime?")
            }
            // API 리퀘스트 진행되는 동안 버튼 disabled
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        // sheet: Binding의 상태를 받아서 모달을 presentation할 수 있음
        .sheet(isPresented: self.$isPrimeModalShown) {
            IsPrimeModalView(state: self.state)
        }
        .alert(item: self.$alertNthPrime) { alert in
            Alert(
                title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }

    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(for: n) ?? ""
    }

    // MARK: 2. Side-Effect를 실행시키는 방법
    // 문제점: 리퀘스트를 중간에 취소하거나 여러 번의 리퀘스트를 묶어주는 디바운스 기능을 사용할 수 없으며 이를 실행시켜볼 수 있는 방법이 없다 (Side-Effect가 제어되지 않음)
    // 해결방법: 아직 SwiftUI는 이에 대한 대안을 제시하지 못했다..
    private func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.state.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        }
        self.isNthPrimeButtonDisabled = false
    }
}

struct IsPrimeModalView: View {

    @ObservedObject var state: AppState

    var body: some View {
        VStack {
            if isPrime(self.state.count) {
                Text("\(self.state.count) is prime 🎉")
                if self.state.favoritePrimes.contains(self.state.count) {
                    Button(action: {
                        self.state.removeFavoritePrime()
                    }) {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button(action: {
                        self.state.addFavoritePrime()
                    }) {
                        Text("Save to favorite primes")
                    }
                }
            } else {
                Text("\(self.state.count) is not prime 😅")
            }

        }
    }

    private func isPrime(_ p: Int) -> Bool {
        if p <= 1 { return false }
        if p <= 3 { return true }
        for i in 2...Int(sqrtf(Float(p))) {
            if p % i == 0 { return false }
        }
        return true
    }
}

struct FavoritePrimesView: View {

    // MARK: 3. 모듈화 하는 방법 (거대한 애플리케이션을 작은 애플리케이션으로 분할하는 방법)
    // 문제점: 모듈화가 어렵다 (AppState 실제로 사용하는 것은 favoritePrimes 하나 뿐이지만 전체를 받고 있음)
    // 해결방법: 아직 SwiftUI는 이에 대한 대안을 제시하지 못했다.. 또는 ObservedObject를 따르는 래퍼 클래스를 만들고 일부만 구현하는 방식으로 해결 가능
//    @ObservedObject var state: AppState

    @Binding var favoritePrimes: [Int]
    @Binding var activityFeed: [AppState.Activity]

    var body: some View {
        List {
            // 테이블뷰화 시킬 수 있도록 List 내부에 ForEach 구문 삽입
            ForEach(self.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
//            .onDelete { self.state.removeFavoritePrimes(at: $0) }
            .onDelete { indexSet in
                for index in indexSet {
                    let prime = self.favoritePrimes[index]
                    self.favoritePrimes.remove(at: index)
                    self.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
                }
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
    }
}

// MARK: 4. 애플리케이션을 테스트하는 방법
// 문제점: 테스트하기 어려운 구조다 (상태나 변화를 일으키는 코드가 뷰에서 서로 얽혀있어 실제 기능이 동작하는지 테스트하기 어렵다

// MARK: - Rendering in a playground

import PlaygroundSupport

// UIHostingController: SwiftUI와 UIKit를 연결하는 작업을 하기 위해 뷰를 감쌌다
PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView(state: AppState())
)

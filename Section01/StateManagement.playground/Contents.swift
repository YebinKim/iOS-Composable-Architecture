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
                NavigationLink(destination: FavoritePrimesView(state: self.state)) {
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
}

struct PrimeAlert: Identifiable {

  let prime: Int

  var id: Int { self.prime }
}

struct CounterView: View {

    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?

    var body: some View {
        VStack {
            HStack {
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

    private func nthPrimeButtonAction() {
        nthPrime(self.state.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        }
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
                        self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })
                    }) {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button(action: {
                        self.state.favoritePrimes.append(self.state.count)
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

    @ObservedObject var state: AppState

    var body: some View {
        List {
            // 테이블뷰화 시킬 수 있도록 List 내부에 ForEach 구문 삽입
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
    }
}

// MARK: - Rendering in a playground

import PlaygroundSupport

// UIHostingController: SwiftUI와 UIKit를 연결하는 작업을 하기 위해 뷰를 감쌌다
PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView(state: AppState())
)

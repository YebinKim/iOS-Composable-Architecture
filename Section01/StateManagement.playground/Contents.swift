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
                NavigationLink(destination: EmptyView()) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
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
}

struct CounterView: View {

    @ObservedObject var state: AppState

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
            Button(action: {}) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
    }
}

// MARK: - Rendering in a playground

import PlaygroundSupport

// UIHostingController: SwiftUI와 UIKit를 연결하는 작업을 하기 위해 뷰를 감쌌다
PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView(state: AppState())
)

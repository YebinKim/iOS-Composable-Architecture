//
//  CounterView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import SwiftUI

struct CounterView: View {

    @ObservedObject var store: Store<AppState, AppAction>
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false

    var body: some View {
        VStack {
            HStack {
                Button("-") {
//                    self.store.value.count -= 1
                    // MARK: 함수형 상태 관리
                    // 버튼의 액션 클로저 내부의 상태를 직접 변경하는 대신 해당 액션 값을 Reducer에 보내고 Reducer가 필요한 모든 변경을 수행함
                    // -> User Custom Action을 선언했다
//                    self.store.value = counterReducer(state: self.store.value, action: .decrTapped)

                    // MARK: Ergonomics: Store 내부에서 Reducer 캡처
//                    self.store.send(.decrTapped)

                    // MARK: Ergonomics: in-out Reducers
//                    counterReducer(value: &state, action: .decrTapped)

                    // MARK: 상태 변화 코드 Store로 이동
                    self.store.send(.counter(.decreaseCount))
                }
                Text("\(self.store.value.count)")
                Button("+") {
//                    self.store.state.count += 1
                    // MARK: 함수형 상태 관리
//                    self.store.value = counterReducer(state: self.store.value, action: .incrTapped)
                    // MARK: Ergonomics: Store 내부에서 Reducer 캡처
//                    self.store.send(.incrTapped)
                    // MARK: Ergonomics: in-out Reducers
//                    counterReducer(value: &state, action: .incrTapped)
                    // MARK: 상태 변화 코드 Store로 이동
                    self.store.send(.counter(.increaseCount))
                }
            }
            Button(action: { self.isPrimeModalShown = true }) {
              Text("Is this prime?")
            }
            Button(action: self.nthPrimeButtonAction) {
              Text("What is the \(ordinal(self.store.value.count)) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: self.$isPrimeModalShown) {
            IsPrimeModalView(store: self.store)
        }
        .alert(item: self.$alertNthPrime) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
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
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.store.value.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        }
        self.isNthPrimeButtonDisabled = false
    }
}

struct PrimeAlert: Identifiable {

  let prime: Int

  var id: Int { self.prime }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(store: Store(initialValue: AppState(), reducer: with(
            appReducer,
            compose(
                logger,
                activityFeed
            )
        )))
    }
}

private func compose<A, B, C>(
    _ f: @escaping (B) -> C,
    _ g: @escaping (A) -> B
)
-> (A) -> C {
    return { (a: A) -> C in
        f(g(a))
    }
}

private func with<A, B>(_ a: A, _ f: (A) throws -> B) rethrows -> B {
    return try f(a)
}

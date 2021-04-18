# iOS-Composable-Architecture
Study Composable Architecture at [Pointfree](https://www.pointfree.co/collections/composable-architecture)



**세 가지 원칙을 중심으로 아키텍쳐를 개발하는 과정을 공부 중!**

> - **Composable** (프로그램의 나머지 부분과 상호 의존하지 않고 자유롭게 정렬하고 재배치 할 수 있기 때문에 변화에 대한 영향이 적음)
> - **Modular** (모듈화 가능)
> - **Testable** (테스트 가능)



## Section 1. SwiftUI and State Management

- 강의 목표: **애플리케이션 아키텍쳐의 필요성을 이해**하고 **SwiftUI가 상태 관리(State Management) 하는 방법을 이해**함으로써 Composable Architecture를 통해 해결하고자 하는 **5가지 문제점**을 정의하는 것
  - 전체 애플리케이션에서 상태를 관리하는 방법
  - 값 타입과 같은 간단한 단위로 아키텍쳐를 모델링하는 방법
  - 애플리케이션의 각 기능을 모듈화하는 방법
  - 애플리케이션에서 Side-Effect를 모델링하는 방법
  - 기능 별 테스트를 쉽게 작성하는 방법



- ### **만들고자 하는 앱: 숫자 카운팅 앱**

  - 소수 판별 기능과 소수를 리스트에 저장/삭제할 수 있는 기능, N번째 소수를 찾는 기능 포함
  - 사용자에게 보여줘야 할 UI의 상태 변경이 많다. (모달을 통해 띄운 컨텐츠는 이전 화면에 의존성을 가짐, 네트워크 리퀘스트 발생 등)
  - 여러 화면에서 유지되어야 하는 상태가 있다. (리스트에 저장한 소수)
  - 앱을 아주 작은 단위의 서브 컴포넌트로 만들 수 있다.
  - N번째 소수를 찾기 위해 사용하는 API가 무분별하게 호출되지 않도록 Side-Effect 처리가 필요하다.



- **앱 개발 후 정리한 애플리케이션 아키텍쳐 관점에서 봤을 때 해결해야 할 문제 4가지**
  - 변화하는 상태를 관리하는 방법
  - Side-Effect를 실행시키는 방법
  - 모듈화 하는 방법
  - 애플리케이션을 테스트하는 방법



## Section 2. Reducers and Stores

- 강의 목표: **값 타입 사용을 지향**하고 **큰 문제를 작게 분할시킬 수 있도록** **Reducer를 활용**하는 방법을 배우고 애플리케이션의 복잡한 **런타임을 stores 라는 단위에 위임**하는 것
  - **Reducers**
    -  글로벌 상태를 모델링하는 더 나은 방법 (값 타입과 ObservableObject 래퍼 사용)
    - 함수형 상태 관리 (Reducer 사용)
    - Ergonomics: Store 내부에서 Reducer 캡처
    - Ergonomics: in-out Reducers
    - 상태 변화 코드 Store로 이동
  
  
  
  - **State Pullbacks**
    - Reducer 결합
    - Reducer의 상태 세분화
    - 상태에 따라 Reducer의 풀백 실행
    - Key-path 풀백
    - 더 많은 Reducer에 풀백 적용
  
  
  
  - **Action Pullbacks**
    - Reducer의 액션 세분화
    - Enum과 Key-path
    - Enum 속성
    - 액션에 따라 Reducer의 풀백 실행
    - 더 많은 Reducer에 풀백 적용
  
  
  
  - **Higher-Order Reducers**
    - 고차 Reducer란?
    - activityFeed에서 고차 Reducer 사용하도록 업데이트
    - logging에서 고차 Reducer 사용하도록 업데이트



## Section 3. Modularity

- 강의 목표: **각 기능을 모듈화**함으로써 애플리케이션의 **각 화면을 독립적으로 실행**할 수 있게 한다.

  - **Reducers**
    - What does modularity mean?
    - Modularizing our reducers
    - Modularizing the Composable Architecture
    - Modularizing the favorite primes reducer
    - Modularizing the counter reducer
    - Modularizing the prime modal reducer

  

  - **View State**
    - Modularizing our views
    - Transforming a store's value
    - A familiar-looking function
    - What's in a name?
    - Propagating global changes locally
    - Focusing on view state

  

  - **View Actions**
    - Transforming a store’s action
    - Combining view functions
    - Focusing on favorite primes actions
    - Extracting our first modular view
    - Focusing on prime modal actions
    - Focusing on counter actions

  

  - **The Point**
    - What’s the point?
    - The favorite primes app
    - The prime modal app
    - The counter app
    - Fixing the root app



## Section 4. Side Effects

- 강의 목표: **사이드 이펙트를 일급 객체로 다룸으로써** 전달 및 제어, 테스트를 용이하게 할 수 있게 한다.

  - **Synchronous Effects**
    - Adding some simple side effects
    - Effects in reducers
    - Reducers as pure functions
    - Effects as values
    - Updating our architecture for effects
    - Reflecting on our first effect

  

  - **Unidirectional Effects**
    - Synchronous effects that produce results
    - Combining multiple effects that produce results
    - Pulling local effects back globally
    - Working with our new effects
    - What’s unidirectional data flow?

  

  - **Asynchronous Effects**
    - Extracting our asynchronous effect
    - Local state to global state
    - The async signature
    - The async effect
    - Refactor-related bugs
    - Thinking unidirectionally

  

  - **The Point**
    - What’s the point?
    - Composable, transformable effects
    - Reusable effects: network requests
    - Reusable effects: threading
    - Getting everything building again

  

  - **The Combine Framework and Effects: Part 1**
    - The Effect type: a quick recap
    - The Combine-Effect Correspondence
    - Publishers
    - Subscribers
    - Eagerness vs. laziness
    - Subjects

  

  - **The Combine Framework and Effects: Part 2**
    - Effect as a Combine publisher
    - Pulling back reducers with publishers
    - Finishing the architecture refactor
    - Refactoring synchronous effects
    - Refactoring asynchronous effects



## Section 5. Testing

- 강의 목표: 지금까지 진행했던 모듈화, 사이드 이펙트를 기반으로 **기능 및 화면에 관한 테스트를 작성**한다, (Composable-Architecture가 얼마나 테스트하기 쉬운지가 키포인트)

  - **Reducers**
    - Testing the prime modal
    - Testing favorite primes
    - Testing the counter
    - Unhappy paths and integration tests

  

  - **Effects**
    - Controlling the favorite primes save effect
    - Controlling the favorite primes load effect
    - Testing the favorite primes save effect
    - Testing the favorite primes load effect
    - Controlling the counter effect
    - Testing the counter effects

  

  - **Ergonomics**
    - Simplifying testing state
    - The shape of a test
    - Improving test feedback
    - Trailing closure ergonomics
    - Actions sent and actions received
    - Assertion edge cases

  

  - **The Point**
    - A tour of the vanilla SwiftUI code base
    - Testing vanilla SwiftUI
    - Testing the prime modal
    - Testing the favorite primes view
    - Testing the counter view: @ObservedObject
    - Testing the counter view: @State



## Section 6. Dependency Management

- 강의 목표: Composable-Architecture에서 **종속성을 쉽게 관리**하기 위해 구조를 수정한다.

  - **Dependency Injection Made Composable**
    - Effects recap
    - Environment recap
    - Current problems
    - Environment in the reducer
    - Environment in the store
    - Erasing the environment from the store

  

  - **Dependency Injection Made Modular**
    - Using the architecture’s environment
    - Tuplizing the environment
    - Testing with the environment
  
  
  
  - **Modular Dependency Injection: The Point**
    - Multiple environments
    - Local dependencies
    - Sharing dependencies



## Section 7. Adaption

- 강의 목표: Composable-Architecture의 성능 향상 및 오류 수정을 진행하고, **다른 OS 환경에서도 사용할 수 있게 **작업을 진행합니다. 

  - **Adaptive State Management: Performance**
    - Fixing a couple memory leaks
    - View.init/body: tracking
    - View.init/body: analysis
    - View.init/body: stress test

  

  - **Adaptive State Management: State**
    - View models and view stores
    - View store performance
    - Counter view performance
    - View store memory management
    - Adapting view stores

  

  - **Adaptive State Management: Actions**
    - Action adaptation
    - View store action sending
    - View actions
    - Tests and the view store

  

  - **Adaptive State Management: The Point**
    - Cross-platform SwiftUI views
    - Dedicated platform SwiftUI views
    - Cross-platform playgrounds



## Section 8. Ergonomics

- 강의 목표: Composable-Architecture를 활용한 작업을 원할하게 할 수 있도록 **코드 사용성 및 가독성 개선 작업을 진행**합니다.

  - **Ergonomic State Management: Part 1**
    - The architecture's surface area
    - Free functions
    - Reducer as a struct
    - Reducer methods
    - Updating the app's modules

  

  - **Ergonomic State Management: Part 2**
    - Dynamic member lookup
    - Dynamic member store
    - Bindings and the architecture
    - Binding helpers



## Section 9. A Tour of the Composable Architecture
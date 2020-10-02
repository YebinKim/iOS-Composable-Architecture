# iOS-Composable-Architecture
Study Composable Architecture at [Pointfree](https://www.pointfree.co/collections/composable-architecture)



**세 가지 원칙을 중심으로 아키텍쳐를 개발하는 과정을 공부 중!**

> - **Composable** (프로그램의 나머지 부분과 상호 의존하지 않고 자유롭게 정렬하고 재배치 할 수 있기 때문에 변화에 대한 영향이 적음)
> - **Modular** (모듈화 가능)
> - **Testable** (테스트 가능)



## Section 1. SwiftUI and State Management

- 강의 목표: **애플리케이션 아키텍쳐의 필요성을 이해**하고 **SwiftUI가 상태 관리(State Management) 하는 방법을 이해**함으로써 Composable Architecture를 통해 해결하고자 하는 **5가지 문제점**을 정의하는 것
  - 전체 애플리케이션에서 상태를 관리하는 방법
  - 값 유형과 같은 간단한 단위로 아키텍쳐를 모델링하는 방법
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
  - Reducers
  - State Pullbacks
  - Action Pullbacks
  - Higher-Order Reducers



## Section 3. Modularity



## Section 4. Side Effects



## Section 5. Testing



## Section 6. Dependency Management



## Section 7. Adaption


Func 델리게이트와 Action 델리게이트는 같은 역활을 합니다.

Action 도 Func 처럼 system 네임스페이스안에 선언이 되어 있죠

 

단 큰 차이점은 위임된 메소드가 처리되고 결과값이 반환되느냐 아니냐 차이입니다.


Func<out TResult>

Func<in T1, out TResult>

Func<in T1,in T2, out TResult>

Func<in T1,in T2,...in T16, out TResult>

Func의 오른쪽 끝의 1개는 Return 타입 , 왼쪽부터 순서대로 매개변수 타입.

Action

Action <in T1>

Action <in T1,in T2>

Action <in T1,in T2,...in T16>

Action은 Void 타입. Return이 없음. 


리턴값이 있는 메서드 혹은 익명 메서드를 Delegate해야 할 경우에는 Func을 사용하고

리턴값이 없이 실행하는 메서드나 익명메서드를 Delegate할 경우에는 Action을 사용한다.

 
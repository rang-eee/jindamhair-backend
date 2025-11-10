package com.jindam.base.base;

import org.springframework.stereotype.Component;
import java.util.ArrayList;
import java.util.List;

/**
 * 테이블 변경 이력을 트랜잭션을 관리하는 클래스
 * 
 * HistoryAppendService를 통해 쌓인 트랜잭션을, Service 가장 후순위 프로세스에서 commit() 호출을 하여 이력 적재를 완료한다. <br />
 * HistoryAppendService를 통해 쌓인 트랜잭션을 되돌려야 할 경우 rollback() 호출
 */
@Component
public class HistoryTransactionManager {
    private static final ThreadLocal<List<Runnable>> HISTORY_OPERATIONS = ThreadLocal.withInitial(ArrayList::new);

    // 히스토리 저장 요청을 임시 저장 (바로 실행하지 않음)
    public void registerHistoryOperation(Runnable operation) {
        HISTORY_OPERATIONS.get()
            .add(operation);
    }

    // 트랜잭션 종료 시 호출 → 히스토리 저장 실행
    public void commit() {
        List<Runnable> operations = HISTORY_OPERATIONS.get();
        if (operations != null) {
            for (Runnable operation : operations) {
                operation.run();
            }
            operations.clear();
        }
        clear();
    }

    // 트랜잭션 롤백 시 호출 → 저장된 히스토리 삭제
    public void rollback() {
        List<Runnable> operations = HISTORY_OPERATIONS.get();

        // 실행 중인 히스토리가 있는 경우에만 롤백 실행
        if (operations != null && !operations.isEmpty()) {
            operations.clear();
            clear(); // ThreadLocal 제거
        }
    }

    // 스레드 종료 시 초기화
    public void clear() {
        HISTORY_OPERATIONS.remove();
    }
}

; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=loop-distribute,loop-vectorize -enable-loop-distribute -force-vector-width=4 -force-vector-interleave=1 -S \
; RUN: %s | FileCheck %s

; This test is to assure LoopAccessInfo invalidation after LoopVectorize
; modifies the IR.
define void @reduced(ptr %0, ptr %1, i64 %iv, ptr %2, i64 %iv76, i64 %iv93) {
; CHECK-LABEL: @reduced(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 [[IV:%.*]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[TMP3]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[TMP3]], 4
; CHECK-NEXT:    [[IND_END:%.*]] = sub i64 [[TMP3]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP8:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[IND_END]]
; CHECK-NEXT:    br i1 [[TMP8]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP3]], [[IND_END]]
; CHECK-NEXT:    [[IND_ESCAPE:%.*]] = sub i64 [[IND_END]], 1
; CHECK-NEXT:    br i1 [[CMP_N]], label [[LOOP_2_PREHEADER:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[BC_RESUME_VAL1:%.*]] = phi i64 [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    br label [[LOOP_1:%.*]]
; CHECK:       loop.1:
; CHECK-NEXT:    [[IV761:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[IV_NEXT77:%.*]], [[LOOP_1]] ]
; CHECK-NEXT:    [[IV4:%.*]] = phi i64 [ [[BC_RESUME_VAL1]], [[SCALAR_PH]] ], [ [[IV_NEXT:%.*]], [[LOOP_1]] ]
; CHECK-NEXT:    [[IV_NEXT77]] = add i64 [[IV761]], 1
; CHECK-NEXT:    [[ARRAYIDX_I_I50:%.*]] = getelementptr i32, ptr [[TMP0:%.*]], i64 [[IV76:%.*]]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV4]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV4]], [[IV]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[LOOP_2_PREHEADER]], label [[LOOP_1]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       loop.2.preheader:
; CHECK-NEXT:    [[IV761_LCSSA:%.*]] = phi i64 [ [[IV761]], [[LOOP_1]] ], [ [[IND_ESCAPE]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    [[MIN_ITERS_CHECK6:%.*]] = icmp ult i64 [[TMP3]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK6]], label [[SCALAR_PH5:%.*]], label [[VECTOR_MEMCHECK:%.*]]
; CHECK:       vector.memcheck:
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, ptr [[TMP1:%.*]], i64 4
; CHECK-NEXT:    [[TMP9:%.*]] = shl i64 [[IV761_LCSSA]], 2
; CHECK-NEXT:    [[SCEVGEP2:%.*]] = getelementptr i8, ptr [[TMP0]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP10:%.*]] = add i64 [[TMP9]], 4
; CHECK-NEXT:    [[SCEVGEP3:%.*]] = getelementptr i8, ptr [[TMP0]], i64 [[TMP10]]
; CHECK-NEXT:    [[BOUND0:%.*]] = icmp ult ptr [[TMP1]], [[SCEVGEP3]]
; CHECK-NEXT:    [[BOUND1:%.*]] = icmp ult ptr [[SCEVGEP2]], [[SCEVGEP]]
; CHECK-NEXT:    [[FOUND_CONFLICT:%.*]] = and i1 [[BOUND0]], [[BOUND1]]
; CHECK-NEXT:    br i1 [[FOUND_CONFLICT]], label [[SCALAR_PH5]], label [[VECTOR_PH6:%.*]]
; CHECK:       vector.ph6:
; CHECK-NEXT:    [[N_MOD_VF8:%.*]] = urem i64 [[TMP3]], 4
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[TMP3]], [[N_MOD_VF8]]
; CHECK-NEXT:    br label [[VECTOR_BODY10:%.*]]
; CHECK:       vector.body9:
; CHECK-NEXT:    [[INDEX12:%.*]] = phi i64 [ 0, [[VECTOR_PH6]] ], [ [[INDEX_NEXT13:%.*]], [[VECTOR_BODY10]] ]
; CHECK-NEXT:    store i32 0, ptr [[TMP1]], align 4, !alias.scope !4, !noalias !7
; CHECK-NEXT:    [[INDEX_NEXT13]] = add nuw i64 [[INDEX12]], 4
; CHECK-NEXT:    [[TMP11:%.*]] = icmp eq i64 [[INDEX_NEXT13]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP11]], label [[MIDDLE_BLOCK12:%.*]], label [[VECTOR_BODY10]], !llvm.loop [[LOOP9:![0-9]+]]
; CHECK:       middle.block12:
; CHECK-NEXT:    [[CMP_N10:%.*]] = icmp eq i64 [[TMP3]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N10]], label [[LOOP_3_LR_PH:%.*]], label [[SCALAR_PH5]]
; CHECK:       scalar.ph4:
; CHECK-NEXT:    [[BC_RESUME_VAL13:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK12]] ], [ 0, [[LOOP_2_PREHEADER]] ], [ 0, [[VECTOR_MEMCHECK]] ]
; CHECK-NEXT:    br label [[LOOP_2:%.*]]
; CHECK:       loop.3.lr.ph:
; CHECK-NEXT:    [[IDXPROM_I_I61:%.*]] = and i64 [[IV761_LCSSA]], 1
; CHECK-NEXT:    [[ARRAYIDX_I_I62:%.*]] = getelementptr i32, ptr [[TMP0]], i64 [[IDXPROM_I_I61]]
; CHECK-NEXT:    [[MIN_ITERS_CHECK22:%.*]] = icmp ult i64 [[TMP3]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK22]], label [[SCALAR_PH21:%.*]], label [[VECTOR_MEMCHECK15:%.*]]
; CHECK:       vector.memcheck15:
; CHECK-NEXT:    [[SCEVGEP15:%.*]] = getelementptr i8, ptr [[TMP1]], i64 4
; CHECK-NEXT:    [[TMP12:%.*]] = shl nuw nsw i64 [[IDXPROM_I_I61]], 2
; CHECK-NEXT:    [[TMP13:%.*]] = add nuw nsw i64 [[TMP12]], 4
; CHECK-NEXT:    [[SCEVGEP16:%.*]] = getelementptr i8, ptr [[TMP0]], i64 [[TMP13]]
; CHECK-NEXT:    [[BOUND017:%.*]] = icmp ult ptr [[TMP1]], [[SCEVGEP16]]
; CHECK-NEXT:    [[BOUND118:%.*]] = icmp ult ptr [[ARRAYIDX_I_I62]], [[SCEVGEP15]]
; CHECK-NEXT:    [[FOUND_CONFLICT19:%.*]] = and i1 [[BOUND017]], [[BOUND118]]
; CHECK-NEXT:    br i1 [[FOUND_CONFLICT19]], label [[SCALAR_PH21]], label [[VECTOR_PH24:%.*]]
; CHECK:       vector.ph23:
; CHECK-NEXT:    [[N_MOD_VF24:%.*]] = urem i64 [[TMP3]], 4
; CHECK-NEXT:    [[N_VEC25:%.*]] = sub i64 [[TMP3]], [[N_MOD_VF24]]
; CHECK-NEXT:    br label [[VECTOR_BODY27:%.*]]
; CHECK:       vector.body26:
; CHECK-NEXT:    [[INDEX29:%.*]] = phi i64 [ 0, [[VECTOR_PH24]] ], [ [[INDEX_NEXT29:%.*]], [[VECTOR_BODY27]] ]
; CHECK-NEXT:    store i32 0, ptr [[TMP1]], align 4, !alias.scope [[META10:![0-9]+]], !noalias [[META13:![0-9]+]]
; CHECK-NEXT:    [[INDEX_NEXT29]] = add nuw i64 [[INDEX29]], 4
; CHECK-NEXT:    [[TMP14:%.*]] = icmp eq i64 [[INDEX_NEXT29]], [[N_VEC25]]
; CHECK-NEXT:    br i1 [[TMP14]], label [[MIDDLE_BLOCK29:%.*]], label [[VECTOR_BODY27]], !llvm.loop [[LOOP15:![0-9]+]]
; CHECK:       middle.block29:
; CHECK-NEXT:    [[CMP_N27:%.*]] = icmp eq i64 [[TMP3]], [[N_VEC25]]
; CHECK-NEXT:    br i1 [[CMP_N27]], label [[LOOP_CLEANUP:%.*]], label [[SCALAR_PH21]]
; CHECK:       scalar.ph21:
; CHECK-NEXT:    [[BC_RESUME_VAL26:%.*]] = phi i64 [ [[N_VEC25]], [[MIDDLE_BLOCK29]] ], [ 0, [[LOOP_3_LR_PH]] ], [ 0, [[VECTOR_MEMCHECK15]] ]
; CHECK-NEXT:    br label [[LOOP_3:%.*]]
; CHECK:       loop.2:
; CHECK-NEXT:    [[IV846:%.*]] = phi i64 [ [[IV_NEXT85:%.*]], [[LOOP_2]] ], [ [[BC_RESUME_VAL13]], [[SCALAR_PH5]] ]
; CHECK-NEXT:    [[IV_NEXT87:%.*]] = add i64 0, 0
; CHECK-NEXT:    [[ARRAYIDX_I_I56:%.*]] = getelementptr i32, ptr [[TMP0]], i64 [[IV761_LCSSA]]
; CHECK-NEXT:    [[TMP15:%.*]] = load i32, ptr [[ARRAYIDX_I_I56]], align 4
; CHECK-NEXT:    store i32 0, ptr [[TMP1]], align 4
; CHECK-NEXT:    [[IV_NEXT85]] = add i64 [[IV846]], 1
; CHECK-NEXT:    [[EXITCOND92_NOT:%.*]] = icmp eq i64 [[IV846]], [[IV]]
; CHECK-NEXT:    br i1 [[EXITCOND92_NOT]], label [[LOOP_3_LR_PH]], label [[LOOP_2]], !llvm.loop [[LOOP16:![0-9]+]]
; CHECK:       loop.3:
; CHECK-NEXT:    [[IV932:%.*]] = phi i64 [ [[BC_RESUME_VAL26]], [[SCALAR_PH21]] ], [ [[IV_NEXT94:%.*]], [[LOOP_3]] ]
; CHECK-NEXT:    [[TMP16:%.*]] = load i32, ptr [[ARRAYIDX_I_I62]], align 4
; CHECK-NEXT:    [[ARRAYIDX_I_I653:%.*]] = getelementptr i32, ptr [[TMP2:%.*]], i64 [[IV93:%.*]]
; CHECK-NEXT:    store i32 0, ptr [[TMP1]], align 4
; CHECK-NEXT:    [[IV_NEXT94]] = add i64 [[IV932]], 1
; CHECK-NEXT:    [[EXITCOND97_NOT:%.*]] = icmp eq i64 [[IV932]], [[IV]]
; CHECK-NEXT:    br i1 [[EXITCOND97_NOT]], label [[LOOP_CLEANUP]], label [[LOOP_3]], !llvm.loop [[LOOP17:![0-9]+]]
; CHECK:       loop.cleanup:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop.1

loop.1:                                         ; preds = %loop.1, %entry
  %iv761 = phi i64 [ 0, %entry ], [ %iv.next77, %loop.1 ]
  %iv4 = phi i64 [ 0, %entry ], [ %iv.next, %loop.1 ]
  %iv.next77 = add i64 %iv761, 1
  %arrayidx.i.i50 = getelementptr i32, ptr %0, i64 %iv76
  %iv.next = add i64 %iv4, 1
  %exitcond.not = icmp eq i64 %iv4, %iv
  br i1 %exitcond.not, label %loop.2.preheader, label %loop.1

loop.2.preheader:                             ; preds = %loop.1
  br label %loop.2

loop.3.lr.ph:                                 ; preds = %loop.2
  %idxprom.i.i61 = and i64 %iv761, 1
  %arrayidx.i.i62 = getelementptr i32, ptr %0, i64 %idxprom.i.i61
  br label %loop.3

loop.2:                                       ; preds = %loop.2, %loop.2.preheader
  %iv846 = phi i64 [ %iv.next85, %loop.2 ], [ 0, %loop.2.preheader ]
  %iv.next87 = add i64 0, 0
  %arrayidx.i.i56 = getelementptr i32, ptr %0, i64 %iv761
  %3 = load i32, ptr %arrayidx.i.i56, align 4
  store i32 0, ptr %1, align 4
  %iv.next85 = add i64 %iv846, 1
  %exitcond92.not = icmp eq i64 %iv846, %iv
  br i1 %exitcond92.not, label %loop.3.lr.ph, label %loop.2

loop.3:                                       ; preds = %loop.3, %loop.3.lr.ph
  %iv932 = phi i64 [ 0, %loop.3.lr.ph ], [ %iv.next94, %loop.3 ]
  %4 = load i32, ptr %arrayidx.i.i62, align 4
  %arrayidx.i.i653 = getelementptr i32, ptr %2, i64 %iv93
  store i32 0, ptr %1, align 4
  %iv.next94 = add i64 %iv932, 1
  %exitcond97.not = icmp eq i64 %iv932, %iv
  br i1 %exitcond97.not, label %loop.cleanup, label %loop.3

loop.cleanup:                               ; preds = %loop.3
  ret void
}

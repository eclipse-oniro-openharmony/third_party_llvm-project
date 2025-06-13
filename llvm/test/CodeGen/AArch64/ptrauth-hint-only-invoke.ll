
; RUN: llc -mtriple aarch64 -mattr=+pauth                  -o - %s \
; RUN:   | FileCheck %s --check-prefixes=CHECK,CHECK-SDAG,ELF,ELF-SDAG

; RUN: llc -mtriple aarch64 -mattr=+pauth,+pauth-hint-only -o - %s \
; RUN:   | FileCheck %s --check-prefixes=CHECK,CHECK-SDAG,HINT,HINT-SDAG


; RUN-NOT: llc -mtriple aarch64 -mattr=+pauth -o - %s \
; RUN-NOT:   -global-isel -global-isel-abort=1 -verify-machineinstrs \
; RUN-NOT:  | FileCheck %s --check-prefixes=CHECK,CHECK-GISEL,ELF,ELF-GISEL

; RUN-NOT: llc -mtriple aarch64 -mattr=+pauth,+pauth-hint-only -o - %s \
; RUN-NOT:   -global-isel -global-isel-abort=1 -verify-machineinstrs \
; RUN-NOT:  | FileCheck %s --check-prefixes=CHECK,CHECK-GISEL,HINT,HINT-GISEL


; CHECK-LABEL: test_invoke_ia_0:
; CHECK:       [[FNBEGIN:.L.*]]:
; CHECK-NEXT:  .cfi_startproc
; CHECK-NEXT:  .cfi_personality 156, DW.ref.__gxx_personality_v0
; CHECK-NEXT:  .cfi_lsda 28, [[EXCEPT:.Lexception[0-9]+]]
; CHECK-NEXT: // %bb.0:
; CHECK-NEXT:  stp x30, x19, [sp, #-16]!
; CHECK-NEXT:  .cfi_def_cfa_offset 16
; CHECK-NEXT:  .cfi_offset w19, -8
; CHECK-NEXT:  .cfi_offset w30, -16

; ELF-NEXT: [[PRECALL:.L.*]]:
; ELF-NEXT:  blraaz x0

; HINT-NEXT:  mov    x17, x0
; HINT-NEXT: [[PRECALL:.L.*]]:
; HINT-NEXT:  mov    x16, xzr
; HINT-NEXT:  autia1716
; HINT-NEXT:  blr    x17

; CHECK-SDAG-NEXT: [[POSTCALL:.L.*]]:
; CHECK-SDAG-NEXT: // %bb.1:
; CHECK-SDAG-NEXT:  mov w19, w0

; CHECK-GISEL-NEXT:  mov w19, w0
; CHECK-GISEL-NEXT: [[POSTCALL:.L.*]]:

; CHECK-NEXT: [[CALLBB:.L.*]]:
; CHECK-NEXT:  bl foo
; CHECK-NEXT:  mov w0, w19
; CHECK-NEXT:  ldp x30, x19, [sp], #16
; CHECK-NEXT:  ret
; CHECK-NEXT: [[LPADBB:.LBB[0-9_]+]]:
; CHECK-NEXT: [[LPAD:.L.*]]:
; CHECK-NEXT:  mov w19, #-1
; CHECK-NEXT:  b [[CALLBB]]

; CHECK-LABEL: GCC_except_table{{.*}}:
; CHECK-NEXT: [[EXCEPT]]:
; CHECK:       .uleb128 [[POSTCALL]]-[[PRECALL]] {{.*}} Call between [[PRECALL]] and [[POSTCALL]]
; CHECK-NEXT:  .uleb128 [[LPAD]]-[[FNBEGIN]]     {{.*}}   jumps to [[LPAD]]
; CHECK-NEXT:  .byte 0                           {{.*}} On action: cleanup

define i32 @test_invoke_ia_0(ptr %arg0) #0 personality ptr @__gxx_personality_v0 {
  %tmp0 = invoke i32 %arg0() [ "ptrauth"(i32 0, i64 0) ] to label %continuebb
            unwind label %unwindbb

unwindbb:
  %tmp1 = landingpad { ptr, i32 } cleanup
  call void @foo()
  ret i32 -1

continuebb:
  call void @foo()
  ret i32 %tmp0
}

@_ZTIPKc = external constant ptr
@hello_str = private unnamed_addr constant [6 x i8] c"hello\00", align 1

; CHECK-LABEL: test_invoke_ib_42_catch:
; CHECK-NEXT: [[FNBEGIN:.L.*]]:
; CHECK-NEXT:         .cfi_startproc
; CHECK-NEXT:         .cfi_personality 156, DW.ref.__gxx_personality_v0
; CHECK-NEXT:         .cfi_lsda 28, [[EXCEPT:.Lexception[0-9]+]]
; CHECK-NEXT: // %bb.0:

; ELF-NEXT:           stp x30, x19, [sp, #-16]!
; ELF-NEXT:           .cfi_def_cfa_offset 16
; ELF-NEXT:           .cfi_offset w19, -8
; ELF-NEXT:           .cfi_offset w30, -16
; ELF-NEXT:           mov x19, x0

; HINT-NEXT:          sub sp, sp, #32
; HINT-NEXT:          stp x30, x19, [sp, #16]
; HINT-NEXT:          .cfi_def_cfa_offset 32
; HINT-NEXT:          .cfi_offset w19, -8
; HINT-NEXT:          .cfi_offset w30, -16
; HINT-NEXT:          str x0, [sp, #8]

; CHECK-NEXT:         mov w0, #8
; CHECK-NEXT:         bl __cxa_allocate_exception
; CHECK-NEXT:         adrp x8, .Lhello_str
; CHECK-NEXT:         add x8, x8, :lo12:.Lhello_str
; CHECK-NEXT:         str x8, [x0]
; CHECK-NEXT: [[PRECALL:.L.*]]:
; CHECK-NEXT:         adrp x1, :got:_ZTIPKc
; CHECK-NEXT:         mov x2, xzr
; CHECK-NEXT:         ldr x1, [x1, :got_lo12:_ZTIPKc]

; ELF-NEXT:           mov x17, #42
; ELF-NEXT:           blrab x19, x17

; HINT-NEXT:          ldr x17, [sp, #8]
; HINT-NEXT:          mov x16, #42
; HINT-NEXT:          autib1716
; HINT-NEXT:          blr x17

; CHECK-NEXT: [[POSTCALL:.L.*]]:
; CHECK-NEXT: // %bb.1:
; CHECK-NEXT: [[LPADBB:.LBB[0-9_]+]]:
; CHECK-NEXT: [[LPAD:.L.*]]:
; CHECK-NEXT:         mov x19, x1
; CHECK-NEXT:         bl __cxa_begin_catch
; CHECK-NEXT:         cmp     w19, #2
; CHECK-NEXT:         b.ne [[EXITBB:.LBB[0-9_]+]]
; CHECK-NEXT: // %bb.3:
; CHECK-NEXT:         bl bar
; CHECK-NEXT: [[EXITBB]]:
; CHECK-NEXT:         bl foo
; CHECK-NEXT:         bl __cxa_end_catch

; ELF-NEXT:           ldp x30, x19, [sp], #16

; HINT-NEXT:          ldp x30, x19, [sp, #16]
; HINT-NEXT:          add sp, sp, #32

; CHECK-NEXT:         ret
; CHECK-NEXT: [[FNEND:.L.*]]:

; CHECK-LABEL: GCC_except_table{{.*}}:
; CHECK-NEXT: [[EXCEPT]]:
; CHECK-NEXT:   .byte   255                       {{.*}} @LPStart Encoding = omit
; CHECK-NEXT:   .byte   156                       {{.*}} @TType Encoding = indirect pcrel sdata8
; CHECK-NEXT:   .uleb128 [[TT:.?L.*]]-[[TTREF:.?L.*]]
; CHECK-NEXT: [[TTREF]]:
; CHECK-NEXT:   .byte   1                         {{.*}} Call site Encoding = uleb128
; CHECK-NEXT:   .uleb128 [[CSEND:.?L.*]]-[[CSBEGIN:.?L.*]]
; CHECK-NEXT: [[CSBEGIN]]:
; CHECK-NEXT:   .uleb128 [[FNBEGIN]]-[[FNBEGIN]]  {{.*}} >> Call Site 1 <<
; CHECK-NEXT:   .uleb128 [[PRECALL]]-[[FNBEGIN]]  {{.*}}   Call between [[FNBEGIN]] and [[PRECALL]]
; CHECK-NEXT:   .byte   0                         {{.*}}     has no landing pad
; CHECK-NEXT:   .byte   0                         {{.*}}   On action: cleanup
; CHECK-NEXT:   .uleb128 [[PRECALL]]-[[FNBEGIN]]  {{.*}} >> Call Site 2 <<
; CHECK-NEXT:   .uleb128 [[POSTCALL]]-[[PRECALL]] {{.*}}   Call between [[PRECALL]] and [[POSTCALL]]
; CHECK-NEXT:   .uleb128 [[LPAD]]-[[FNBEGIN]]     {{.*}}     jumps to [[LPAD]]
; CHECK-NEXT:   .byte   3                         {{.*}}   On action: 2
; CHECK-NEXT:   .uleb128 [[POSTCALL]]-[[FNBEGIN]] {{.*}} >> Call Site 3 <<
; CHECK-NEXT:   .uleb128 [[FNEND]]-[[POSTCALL]]   {{.*}}   Call between [[POSTCALL]] and [[FNEND]]
; CHECK-NEXT:   .byte   0                         {{.*}}     has no landing pad
; CHECK-NEXT:   .byte   0                         {{.*}}   On action: cleanup
; CHECK-NEXT: [[CSEND]]:
; CHECK-NEXT:   .byte   1                         {{.*}} >> Action Record 1 <<
; CHECK-NEXT:                                     {{.*}}   Catch TypeInfo 1
; CHECK-NEXT:   .byte   0                         {{.*}}   No further actions
; CHECK-NEXT:   .byte   2                         {{.*}} >> Action Record 2 <<
; CHECK-NEXT:                                     {{.*}}   Catch TypeInfo 2
; CHECK-NEXT:   .byte   125                       {{.*}}   Continue to action 1
; CHECK-NEXT:   .p2align   2
; CHECK-NEXT:                                     {{.*}} >> Catch TypeInfos <<
; CHECK-NEXT:    [[TI:.?L.*]]:                      {{.*}} TypeInfo 2
; CHECK-NEXT:     .xword  .L_ZTIPKc.DW.stub-[[TI]]
; CHECK-NEXT:     .xword   0                        {{.*}} TypeInfo 1
; CHECK-NEXT: [[TT]]:

define void @test_invoke_ib_42_catch(ptr %fptr) #0 personality ptr @__gxx_personality_v0 {
  %tmp0 = call ptr @__cxa_allocate_exception(i64 8)
  store ptr getelementptr inbounds ([6 x i8], ptr @hello_str, i64 0, i64 0), ptr %tmp0, align 8
  invoke void %fptr(ptr %tmp0, ptr @_ZTIPKc, ptr null) [ "ptrauth"(i32 1, i64 42) ]
          to label %continuebb unwind label %catchbb

catchbb:
  %tmp2 = landingpad { ptr, i32 }
          catch ptr @_ZTIPKc
          catch ptr null
  %tmp3 = extractvalue { ptr, i32 } %tmp2, 0
  %tmp4 = extractvalue { ptr, i32 } %tmp2, 1
  %tmp5 = call i32 @llvm.eh.typeid.for(ptr @_ZTIPKc)
  %tmp6 = icmp eq i32 %tmp4, %tmp5
  %tmp7 = call ptr @__cxa_begin_catch(ptr %tmp3)
  br i1 %tmp6, label %PKc_catchbb, label %any_catchbb

PKc_catchbb:
  call void @bar(ptr %tmp7)
  br label %any_catchbb

any_catchbb:
  call void @foo()
  call void @__cxa_end_catch()
  ret void

continuebb:
  unreachable
}


; CHECK-LABEL: test_invoke_ia_0_direct:
; CHECK-NEXT: [[FNBEGIN:.L.*]]:
; CHECK-NEXT:  .cfi_startproc
; CHECK-NEXT:  .cfi_personality 156, DW.ref.__gxx_personality_v0
; CHECK-NEXT:  .cfi_lsda 28, [[EXCEPT:.Lexception[0-9]+]]
; CHECK-NEXT: // %bb.0:
; CHECK-NEXT:  stp x30, x19, [sp, #-16]!
; CHECK-NEXT:  .cfi_def_cfa_offset 16
; CHECK-NEXT:  .cfi_offset w19, -8
; CHECK-NEXT:  .cfi_offset w30, -16
; CHECK-NEXT: [[PRECALL:.L.*]]:
; CHECK-NEXT:  bl baz

; CHECK-SDAG-NEXT: [[POSTCALL:.L.*]]:
; CHECK-SDAG-NEXT: // %bb.1:
; CHECK-SDAG-NEXT:  mov w19, w0

; CHECK-GISEL-NEXT:  mov w19, w0
; CHECK-GISEL-NEXT: [[POSTCALL:.L.*]]:

; CHECK-NEXT: [[CALLBB:.L.*]]:
; CHECK-NEXT:  bl foo
; CHECK-NEXT:  mov w0, w19
; CHECK-NEXT:  ldp x30, x19, [sp], #16
; CHECK-NEXT:  ret
; CHECK-NEXT: [[LPADBB:.LBB[0-9_]+]]:
; CHECK-NEXT: [[LPAD:.L.*]]:
; CHECK-NEXT:  mov w19, #-1
; CHECK-NEXT:  b [[CALLBB]]

; CHECK-LABEL: GCC_except_table{{.*}}:
; CHECK-NEXT: [[EXCEPT]]:
; CHECK:       .uleb128 [[POSTCALL]]-[[PRECALL]] {{.*}} Call between [[PRECALL]] and [[POSTCALL]]
; CHECK-NEXT:  .uleb128 [[LPAD]]-[[FNBEGIN]]     {{.*}}   jumps to [[LPAD]]
; CHECK-NEXT:  .byte 0                           {{.*}} On action: cleanup

define i32 @test_invoke_ia_0_direct() #0 personality ptr @__gxx_personality_v0 {
  %tmp0 = invoke i32 ptrauth (ptr @baz, i32 0)() [ "ptrauth"(i32 0, i64 0) ] to label %continuebb
            unwind label %unwindbb

unwindbb:
  %tmp1 = landingpad { ptr, i32 } cleanup
  call void @foo()
  ret i32 -1

continuebb:
  call void @foo()
  ret i32 %tmp0
}

; CHECK-LABEL: test_invoke_ib_2_direct_mismatch:
; CHECK-NEXT: [[FNBEGIN:.L.*]]:
; CHECK-NEXT:  .cfi_startproc
; CHECK-NEXT:  .cfi_personality 156, DW.ref.__gxx_personality_v0
; CHECK-NEXT:  .cfi_lsda 28, [[EXCEPT:.Lexception[0-9]+]]
; CHECK-NEXT: // %bb.0:
; CHECK-NEXT:  stp x30, x19, [sp, #-16]!
; CHECK-NEXT:  .cfi_def_cfa_offset 16
; CHECK-NEXT:  .cfi_offset w19, -8
; CHECK-NEXT:  .cfi_offset w30, -16

; CHECK-SDAG-NEXT: [[PRECALL:.L.*]]:
; CHECK-SDAG-NEXT:  adrp x17, :got:baz
; CHECK-SDAG-NEXT:  ldr x17, [x17, :got_lo12:baz]
; CHECK-SDAG-NEXT:  mov x16, #1234

; ELF-SDAG-NEXT:    pacia x17, x16
; ELF-SDAG-NEXT:    mov x8, x17
; ELF-SDAG-NEXT:    mov x17, #2
; ELF-SDAG-NEXT:    blrab x8, x17

; HINT-SDAG-NEXT:   pacia1716
; HINT-SDAG-NEXT:   mov x16, #2
; HINT-SDAG-NEXT:   autib1716
; HINT-SDAG-NEXT:   blr x17

; CHECK-SDAG-NEXT: [[POSTCALL:.L.*]]:
; CHECK-SDAG-NEXT: // %bb.1:
; CHECK-SDAG-NEXT:  mov w19, w0

; CHECK-GISEL-NEXT:  adrp x17, :got:baz
; CHECK-GISEL-NEXT:  ldr x17, [x17, :got_lo12:baz]
; CHECK-GISEL-NEXT:  mov x16, #1234

; ELF-GISEL-NEXT:    pacia x17, x16
; ELF-GISEL-NEXT:    mov x8, x17
; ELF-GISEL-NEXT:   [[PRECALL:.L.*]]:
; ELF-GISEL-NEXT:    mov x16, #2
; ELF-GISEL-NEXT:    blrab x8, x16

; HINT-GISEL-NEXT:   pacia1716
; HINT-GISEL-NEXT:  [[PRECALL:.L.*]]:
; HINT-GISEL-NEXT:   mov x16, #2
; HINT-GISEL-NEXT:   autib1716
; HINT-GISEL-NEXT:   blr x17

; CHECK-GISEL-NEXT:  mov w19, w0
; CHECK-GISEL-NEXT: [[POSTCALL:.L.*]]:

; CHECK-NEXT: [[CALLBB:.L.*]]:
; CHECK-NEXT:  bl foo
; CHECK-NEXT:  mov w0, w19
; CHECK-NEXT:  ldp x30, x19, [sp], #16
; CHECK-NEXT:  ret
; CHECK-NEXT: [[LPADBB:.LBB[0-9_]+]]:
; CHECK-NEXT: [[LPAD:.L.*]]:
; CHECK-NEXT:  mov w19, #-1
; CHECK-NEXT:  b [[CALLBB]]

; CHECK-LABEL: GCC_except_table{{.*}}:
; CHECK-NEXT: [[EXCEPT]]:
; CHECK:       .uleb128 [[POSTCALL]]-[[PRECALL]] {{.*}} Call between [[PRECALL]] and [[POSTCALL]]
; CHECK-NEXT:  .uleb128 [[LPAD]]-[[FNBEGIN]]     {{.*}}   jumps to [[LPAD]]
; CHECK-NEXT:  .byte 0                           {{.*}} On action: cleanup

define i32 @test_invoke_ib_2_direct_mismatch() #0 personality ptr @__gxx_personality_v0 {
  %tmp0 = invoke i32 ptrauth (ptr @baz, i32 0, i64 1234)() [ "ptrauth"(i32 1, i64 2) ] to label %continuebb
            unwind label %unwindbb

unwindbb:
  %tmp1 = landingpad { ptr, i32 } cleanup
  call void @foo()
  ret i32 -1

continuebb:
  call void @foo()
  ret i32 %tmp0
}

; CHECK-LABEL:  .L_ZTIPKc.DW.stub:
; CHECK-NEXT:     .xword  _ZTIPKc

declare void @foo()
declare void @bar(ptr)
declare i32 @baz()

declare i32 @__gxx_personality_v0(...)
declare ptr @__cxa_allocate_exception(i64)
declare void @__cxa_throw(ptr, ptr, ptr)
declare i32 @llvm.eh.typeid.for(ptr)
declare ptr @__cxa_begin_catch(ptr)
declare void @__cxa_end_catch()

attributes #0 = { nounwind }

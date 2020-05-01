func foo(value: MyStruct) {
  value./*HERE*/
}

// RUN: DEPCHECK_INTERVAL=1
// RUN: SLEEP_TIME=2

// RUN: %empty-directory(%t)

// RUN: %sourcekitd-test \
// RUN:   -req=global-config -completion-check-dependency-interval ${DEPCHECK_INTERVAL} == \

// RUN:   -shell -- echo "### Initial" == \
// RUN:   -req=complete -pos=2:9 -pass-as-sourcetext -vfs-files=%t/VFS/Main.swift=@%s,%t/VFS/Library.swift=@%S/Inputs/checkdeps/MyProject/Library.swift %t/VFS/Main.swift -- -target %target-triple %t/VFS/Main.swift %t/VFS/Library.swift == \

// RUN:   -shell -- echo "### Modify" == \
// RUN:   -shell -- sleep ${SLEEP_TIME} == \
// RUN:   -req=complete -pos=2:9 -pass-as-sourcetext -vfs-files=%t/VFS/Main.swift=@%s,%t/VFS/Library.swift=@%S/Inputs/checkdeps/MyProject_mod/Library.swift %t/VFS/Main.swift -- -target %target-triple %t/VFS/Main.swift %t/VFS/Library.swift == \

// RUN:   -shell -- echo "### Keep" == \
// RUN:   -shell -- sleep ${SLEEP_TIME} == \
// RUN:   -req=complete -pos=2:9 -pass-as-sourcetext -vfs-files=%t/VFS/Main.swift=@%s,%t/VFS/Library.swift=@%S/Inputs/checkdeps/MyProject_mod/Library.swift %t/VFS/Main.swift -- -target %target-triple %t/VFS/Main.swift %t/VFS/Library.swift \

// RUN:   |  %FileCheck %s

// CHECK-LABEL: ### Initial
// CHECK: key.results: [
// CHECK-DAG: key.description: "myStructMethod()"
// CHECK-DAG: key.description: "self"
// CHECK: ]
// CHECK-NOT: key.reusingastcontext: 1

// CHECK-LABEL: ### Modify
// CHECK: key.results: [
// CHECK-DAG: key.description: "myStructMethod_mod()"
// CHECK-DAG: key.description: "self"
// CHECK: ]
// CHECK-NOT: key.reusingastcontext: 1

// CHECK-LABEL: ### Keep
// CHECK: key.results: [
// CHECK-DAG: key.description: "myStructMethod_mod()"
// CHECK-DAG: key.description: "self"
// CHECK: ]
// CHECK: key.reusingastcontext: 1

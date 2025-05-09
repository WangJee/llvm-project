// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func.func @load_too_many_subscripts_map(%arg0: memref<?x?xf32>, %arg1: index, %arg2: index, %arg3: index) {
  // expected-error@+1 {{op expects as many subscripts as affine map inputs}}
  "affine.load"(%arg0, %arg1, %arg2, %arg3)
    {map = affine_map<(i, j) -> (i, j)> } : (memref<?x?xf32>, index, index, index) -> f32
}

// -----

func.func @load_too_few_subscripts_map(%arg0: memref<?x?xf32>, %arg1: index) {
  // expected-error@+1 {{op expects as many subscripts as affine map inputs}}
  "affine.load"(%arg0, %arg1)
    {map = affine_map<(i, j) -> (i, j)> } : (memref<?x?xf32>, index) -> f32
}

// -----

func.func @store_too_many_subscripts_map(%arg0: memref<?x?xf32>, %arg1: index, %arg2: index,
                                    %arg3: index, %val: f32) {
  // expected-error@+1 {{op expects as many subscripts as affine map inputs}}
  "affine.store"(%val, %arg0, %arg1, %arg2, %arg3)
    {map = affine_map<(i, j) -> (i, j)> } : (f32, memref<?x?xf32>, index, index, index) -> ()
}

// -----

func.func @store_too_few_subscripts_map(%arg0: memref<?x?xf32>, %arg1: index, %val: f32) {
  // expected-error@+1 {{op expects as many subscripts as affine map inputs}}
  "affine.store"(%val, %arg0, %arg1)
    {map = affine_map<(i, j) -> (i, j)> } : (f32, memref<?x?xf32>, index) -> ()
}

// -----

func.func @load_non_affine_index(%arg0 : index) {
  %0 = memref.alloc() : memref<10xf32>
  affine.for %i0 = 0 to 10 {
    %1 = arith.muli %i0, %arg0 : index
    // expected-error@+1 {{op operand cannot be used as a dimension id}}
    %v = affine.load %0[%1] : memref<10xf32>
  }
  return
}

// -----

func.func @store_non_affine_index(%arg0 : index) {
  %0 = memref.alloc() : memref<10xf32>
  %1 = arith.constant 11.0 : f32
  affine.for %i0 = 0 to 10 {
    %2 = arith.muli %i0, %arg0 : index
    // expected-error@+1 {{op operand cannot be used as a dimension id}}
    affine.store %1, %0[%2] : memref<10xf32>
  }
  return
}

// -----

func.func @invalid_prefetch_rw(%i : index) {
  %0 = memref.alloc() : memref<10xf32>
  // expected-error@+1 {{rw specifier has to be 'read' or 'write'}}
  affine.prefetch %0[%i], rw, locality<0>, data  : memref<10xf32>
  return
}

// -----

func.func @invalid_prefetch_cache_type(%i : index) {
  %0 = memref.alloc() : memref<10xf32>
  // expected-error@+1 {{cache type has to be 'data' or 'instr'}}
  affine.prefetch %0[%i], read, locality<0>, false  : memref<10xf32>
  return
}

// -----

func.func @dma_start_non_affine_src_index(%arg0 : index) {
  %0 = memref.alloc() : memref<100xf32>
  %1 = memref.alloc() : memref<100xf32, 2>
  %2 = memref.alloc() : memref<1xi32, 4>
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
  affine.for %i0 = 0 to 10 {
    %3 = arith.muli %i0, %arg0 : index
    // expected-error@+1 {{op src index must be a valid dimension or symbol identifier}}
    affine.dma_start %0[%3], %1[%i0], %2[%c0], %c64
        : memref<100xf32>, memref<100xf32, 2>, memref<1xi32, 4>
  }
  return
}

// -----

func.func @dma_start_non_affine_dst_index(%arg0 : index) {
  %0 = memref.alloc() : memref<100xf32>
  %1 = memref.alloc() : memref<100xf32, 2>
  %2 = memref.alloc() : memref<1xi32, 4>
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
  affine.for %i0 = 0 to 10 {
    %3 = arith.muli %i0, %arg0 : index
    // expected-error@+1 {{op dst index must be a valid dimension or symbol identifier}}
    affine.dma_start %0[%i0], %1[%3], %2[%c0], %c64
        : memref<100xf32>, memref<100xf32, 2>, memref<1xi32, 4>
  }
  return
}

// -----

func.func @dma_start_non_affine_tag_index(%arg0 : index) {
  %0 = memref.alloc() : memref<100xf32>
  %1 = memref.alloc() : memref<100xf32, 2>
  %2 = memref.alloc() : memref<1xi32, 4>
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
  affine.for %i0 = 0 to 10 {
    %3 = arith.muli %i0, %arg0 : index
    // expected-error@+1 {{op tag index must be a valid dimension or symbol identifier}}
    affine.dma_start %0[%i0], %1[%arg0], %2[%3], %c64
        : memref<100xf32>, memref<100xf32, 2>, memref<1xi32, 4>
  }
  return
}

// -----

func.func @dma_wait_non_affine_tag_index(%arg0 : index) {
  %0 = memref.alloc() : memref<100xf32>
  %1 = memref.alloc() : memref<100xf32, 2>
  %2 = memref.alloc() : memref<1xi32, 4>
  %c0 = arith.constant 0 : index
  %c64 = arith.constant 64 : index
  affine.for %i0 = 0 to 10 {
    %3 = arith.muli %i0, %arg0 : index
    // expected-error@+1 {{op index must be a valid dimension or symbol identifier}}
    affine.dma_wait %2[%3], %c64 : memref<1xi32, 4>
  }
  return
}

// -----

func.func @invalid_symbol() {
  %alloc = memref.alloc() {alignment = 64 : i64} : memref<23x26xf32>
  affine.for %arg1 = 0 to 1 {
    affine.for %arg2 = 0 to 26 {
      affine.for %arg3 = 0 to 23 {
        affine.load %alloc[symbol(%arg1) * 23 + symbol(%arg3), %arg2] : memref<23x26xf32>
        // expected-error@above {{op operand cannot be used as a symbol}}
      }
    }
  }
  return
}

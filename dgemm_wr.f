      SUBROUTINE DGEMM_WR ( ,TA,TB,M,N,K
     2,AL,A,LDA,B,LDB,BT,C,LDC)
      SUBROUTINE DGEMM_WR ( cublas_error, cublas_handle, TRANSA, TRANSB, M, N,
     2                      K, ALPHA, A, LDA, B, LDB, BETA, C, LDC )
      use iso_c_binding
c     .. Arguments ..
      implicit none
      real*8   ALPHA, BETA
      integer(c_int)   :: cublas_error, TRANSA, TRANSB
      type(c_ptr) :: cublas_handle

      INTEGER            M, N, K, LDA, LDB, LDC
       real*8   A( LDA, * ), B( LDB, * ), C( LDC, * )

      !$omp target data use_device_ptr(aa,bb,cc_gpu)
       cublas_error = cublasDgemm_v2( cublas_handle, TRANSA, TRANSB, M, N,
     2                                K, AL, A, LDA, B, LDB, BT, C, LDC);
       return
       end

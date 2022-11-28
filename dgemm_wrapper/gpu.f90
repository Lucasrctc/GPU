subroutine mgpu(SIZE,AA,BB,CC)
  use iso_c_binding
  use cudafor
  implicit none
  enum, bind(c) !:: cublasStatus_t
    enumerator :: CUBLAS_STATUS_SUCCESS = 0
    enumerator :: CUBLAS_STATUS_NOT_INITIALIZED = 1
    enumerator :: CUBLAS_STATUS_ALLOC_FAILED = 3
    enumerator :: CUBLAS_STATUS_INVALID_VALUE = 7
    enumerator :: CUBLAS_STATUS_ARCH_MISMATCH = 8
    enumerator :: CUBLAS_STATUS_MAPPING_ERROR = 11
    enumerator :: CUBLAS_STATUS_EXECUTION_FAILED = 13
    enumerator :: CUBLAS_STATUS_INTERNAL_ERROR = 14
  end enum !cublasStatus_t

  enum, bind(c) !:: cublasOperation_t
    enumerator :: CUBLAS_OP_N = 0
    enumerator :: CUBLAS_OP_T = 1
    enumerator :: CUBLAS_OP_C = 2
  end enum !cublasOperation_t

  interface
         integer(c_int) function &
         cublasCreate_v2(handle) &
         bind(c, name="cublasCreate_v2")
      use, intrinsic :: iso_c_binding
      type(c_ptr) :: handle
    end function cublasCreate_v2

    integer(c_int) function &
         cublasDestroy_v2(handle) &
         bind(c, name="cublasDestroy_v2")
      use, intrinsic :: iso_c_binding
      type(c_ptr), value :: handle
    end function cublasDestroy_v2

    integer(c_int) function &
         cudaDeviceSynchronize_v2() &
         bind(c, name="cudaDeviceSynchronize")
      use, intrinsic :: iso_c_binding
    end function cudaDeviceSynchronize_v2

    integer(c_int) function &
         cublasDgemm_v2(handle, transa, transb, m, n, k, alpha, dA,&
         ldda, dB, lddb, beta, dC, lddc) &
         bind(c, name="cublasDgemm_v2")
      use, intrinsic :: iso_c_binding
      type(c_ptr), value :: handle
      integer(c_int), value :: transa
      integer(c_int), value :: transb
      integer(c_int), value :: m
      integer(c_int), value :: n
      integer(c_int), value :: k
      real(c_double) :: alpha
      type(c_ptr), value :: dA
      integer(c_int), value :: ldda
      type(c_ptr), value :: dB
      integer(c_int), value :: lddb
      real(c_double) :: beta
      type(c_ptr), value :: dC
      integer(c_int), value :: lddc
    end function cublasDgemm_v2


  end interface
  double precision, dimension(:),intent(in) :: aa
  double precision, dimension(:),intent(in) :: bb
  double precision, dimension(:),intent(out) :: cc
  double precision, allocatable, target, dimension(:) :: aa_dev
  double precision, allocatable, target, dimension(:) :: bb_dev
  double precision, allocatable, target, dimension(:) :: cc_dev

  integer :: status, SIZE, i, ic, ib, ia, error
  integer(c_int)   :: cublas_error
  type(c_ptr)      :: cublas_handle
  double precision :: rand
  external rand
  double precision, target :: alpha, beta
  integer :: istat, nDevices
  type (cudaDeviceProp) :: prop

  error = 0
  alpha = 1d0
  beta = 0d0

  istat = cudaGetDeviceCount(nDevices)
  do i = 0, nDevices-1
     istat = cudaGetDeviceProperties(prop, i)
     write(*,"(' Device Number: ',i0)") i
     write(*,"('   Device name: ',a)") trim(prop%name)
     write(*,"('   Memory Clock Rate (KHz): ', i0)") &
       prop%memoryClockRate
     write(*,"('   Memory Bus Width (bits): ', i0)") &
       prop%memoryBusWidth
     write(*,"('   Peak Memory Bandwidth (GB/s): ', f6.2)") &
       2.0*prop%memoryClockRate*(prop%memoryBusWidth/8)/10.0**6
     write(*,*)
  enddo

! create cublas handle
  cublas_error = cublascreate_v2(cublas_handle)

  allocate(aa_dev(SIZE*SIZE),stat=status)
  if (status.ne.0) then
          print *,"Alloc went wrong:",status
  endif
  allocate(bb_dev(SIZE*SIZE),stat=status)
  if (status.ne.0) then
          print *,"Alloc went wrong:",status
  endif
  allocate(cc_dev(SIZE*SIZE),stat=status)
  if (status.ne.0) then
          print *,"Alloc went wrong:",status
  endif



  aa_dev=aa
  cc_dev=0.0d0
  bb_dev=bb

!$omp target enter data map(to:aa_dev,bb_dev,cc_dev)
!$omp target data use_device_ptr(aa_dev,bb_dev,cc_dev)
  cublas_error = cublasDgemm_v2(cublas_handle,CUBLAS_OP_N, CUBLAS_OP_N, SIZE, SIZE,SIZE, alpha, c_loc(aa_dev), &
       SIZE, c_loc(bb_dev), SIZE, beta, c_loc(cc_dev), SIZE);
!$omp end target data
   if(cublas_error .ne. CUBLAS_STATUS_SUCCESS ) then
      print *, "failed", cublas_error, cc_dev(1)
      call exit(1)
   endif

   ! wait for call to finish
   cublas_error = cudaDeviceSynchronize_v2()
!   print *, "cuda synchronized", cublas_error
  cublas_error = cublasDestroy_v2(cublas_handle)
 !  print *, "cuda handle destroyed", cublas_error

!$omp target exit data map(from:cc_dev)
        cc=cc_dev
end subroutine mgpu


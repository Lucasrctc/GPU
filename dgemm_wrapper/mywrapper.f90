module mywrapper
        implicit none
          interface
    subroutine mgpu(SIZE,AA,BB,CC)
            use iso_c_binding
            integer :: SIZE
            double precision, dimension(:)::AA
            double precision, dimension(:)::BB
            double precision, dimension(:)::CC
     end subroutine mgpu
  end interface
  end module mywrapper

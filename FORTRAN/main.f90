subroutine test

 

integer, parameter :: Ntotal = 75000

integer, parameter :: dp = selected_real_kind(15)

real(dp), allocatable :: temp(:)

integer :: i, Nsum

 

allocate(temp(Ntotal), source=0.0_dp)

 

! initialize values

!$omp target teams distribute parallel do map(always, from:temp)

do i = 1, Ntotal

  temp(i) = i

enddo

 

! do a sum

Nsum = 0

!$omp target teams distribute parallel do reduction(+: Nsum)

do i = 1, Ntotal

  Nsum = Nsum + temp(i)

enddo

 

write(*,*) "Nsum = ", Nsum

end subroutine test

 

program main

      call test()

      write (*,*) 'hello'

end program

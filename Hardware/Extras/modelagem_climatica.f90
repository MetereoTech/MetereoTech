program ModelagemClimaticaAvancada
    implicit none
    character(len=100) :: csv_file_input = "resultado.csv"
    character(len=100) :: csv_file_output = "previsao.csv"
    integer, parameter :: max_records = 10000, num_vars = 6
    integer :: i, j, unit_input, unit_output, info
    real, dimension(max_records, num_vars) :: Data, Predictions
    real, dimension(num_vars) :: beta
    real, dimension(num_vars, num_vars) :: XTX
    real, dimension(num_vars) :: XTY, X(max_records, num_vars)
    integer :: ipiv(num_vars)

    ! Open files
    open(newunit=unit_input, file=csv_file_input, status='old', action='read')
    open(newunit=unit_output, file=csv_file_output, status='replace', action='write')

    ! Read data from CSV and store in matrix
    do i = 1, max_records
        read(unit_input, *, end=100) (Data(i, j), j = 1, num_vars)
    end do
100 continue

    ! Compute and store predictions for each variable
    do j = 1, num_vars
        ! Set up predictors and compute coefficients
        call SetUpPredictors(Data, X, j, num_vars, i)
        call ComputeCoefficients(Data(:, j), X, beta, num_vars, i)

        ! Predict using the model and store predictions
        do k = 1, i
            Predictions(k, j) = sum(beta * X(k, :))
        end do
    end do

    ! Write header to output file
    write(unit_output, '(6(A, 1X))') (trim(adjustl('Pred_' // char(j + 48))), j = 1, num_vars)

    ! Write predictions to output
    do k = 1, i
        write(unit_output, '(6(F8.2, 1X))') (Predictions(k, j), j = 1, num_vars)
    end do

    ! Close files
    close(unit_input)
    close(unit_output)

contains
    subroutine SetUpPredictors(Data, X, target_idx, num_vars, num_records)
        real, intent(in) :: Data(:,:)
        real, intent(out) :: X(:,:)
        integer, intent(in) :: target_idx, num_vars, num_records
        integer :: i, m

        do i = 1, num_records
            m = 1
            do j = 1, num_vars
                if (j /= target_idx) then
                    X(i, m) = Data(i, j)
                    m = m + 1
                end if
            end do
        end do
    end subroutine SetUpPredictors

    subroutine ComputeCoefficients(Y, X, beta, num_predictors, num_records)
        real, intent(in) :: Y(:), X(:,:)
        real, intent(out) :: beta(:)
        real :: XTX(num_predictors, num_predictors), XTY(num_predictors)
        integer :: ipiv(num_predictors), info, i, j, k

        ! Build the matrices for the normal equations
        XTX = 0.0
        XTY = 0.0
        do i = 1, num_records
            do j = 1, num_predictors
                XTY(j) = XTY(j) + Y(i) * X(i, j)
                do k = 1, num_predictors
                    XTX(j, k) = XTX(j, k) + X(i, j) * X(i, k)
                end do
            end do
        end do

        ! Solve the normal equations using LU decomposition
        call DGESV(num_predictors, 1, XTX, num_predictors, ipiv, XTY, num_predictors, info)
        beta = XTY
    end subroutine ComputeCoefficients
end program ModelagemClimaticaAvancada

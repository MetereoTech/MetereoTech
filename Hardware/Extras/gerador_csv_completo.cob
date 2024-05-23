IDENTIFICATION DIVISION.
PROGRAM-ID. IntegracaoMeteorologica.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT Resultados ASSIGN TO 'resultados.csv'
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT Previsoes ASSIGN TO 'previsoes.csv'
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT FinalFile ASSIGN TO 'final.csv'
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD Resultados.
01 ResultadosRecord PIC X(1000).

FD Previsoes.
01 PrevisoesRecord PIC X(1000).

FD FinalFile.
01 FinalRecord PIC X(2048).

WORKING-STORAGE SECTION.
01 EOFResultados PIC X VALUE 'N'.
   88 EOFResultadosReached VALUE 'Y'.
   88 MoreResultados VALUE 'N'.
01 EOFPrevisoes PIC X VALUE 'N'.
   88 EOFPrevisoesReached VALUE 'Y'.
   88 MorePrevisoes VALUE 'N'.
01 headerLine PIC X(2048) VALUE "TemperaturaMedia;TemperaturaMinima;TemperaturaMaxima;UmidadeSoloMedia;UmidadeSoloMinima;UmidadeSoloMaxima;UmidadeArMedia;UmidadeArMinima;UmidadeArMaxima;LuminosidadeMedia;LuminosidadeMinima;LuminosidadeMaxima;PressaoAtmosfericaMedia;PressaoAtmosfericaMinima;PressaoAtmosfericaMaxima;QualidadeArMedia;QualidadeArMinima;QualidadeArMaxima;TemperaturaPrevista;UmidadeSoloPrevista;UmidadeArPrevista;LuminosidadePrevista;PressaoAtmosfericaPrevista;QualidadeArPrevista".

PROCEDURE DIVISION.
MAIN-LOGIC SECTION.
    PERFORM OPEN-FILES
    WRITE FinalRecord FROM headerLine
    PERFORM PROCESS-FILES UNTIL EOFResultadosReached OR EOFPrevisoesReached
    PERFORM CLOSE-FILES
    DISPLAY "Integration with business systems completed."
    STOP RUN.

OPEN-FILES.
    OPEN INPUT Resultados Previsoes
    OPEN OUTPUT FinalFile

PROCESS-FILES.
    READ Resultados INTO ResultadosRecord AT END
        MOVE 'Y' TO EOFResultados
    READ Previsoes INTO PrevisoesRecord AT END
        MOVE 'Y' TO EOFPrevisoes
    IF NOT EOFResultadosReached AND NOT EOFPrevisoesReached THEN
        PERFORM COMBINE-RECORDS

COMBINE-RECORDS.
    INITIALIZE FinalRecord
    STRING ResultadosRecord DELIMITED BY SIZE
           ';' INTO FinalRecord
    STRING PrevisoesRecord DELIMITED BY SIZE
           ';' INTO FinalRecord
    WRITE FinalRecord FROM FinalRecord
    DISPLAY "Record combined and written to final.csv."

CLOSE-FILES.
    CLOSE Resultados Previsoes FinalFile
    DISPLAY "Files closed successfully."

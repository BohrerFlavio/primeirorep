#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch' 
#INCLUDE "TOTVS.CH" 
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDTI137    บ Autor ณ Daniel de Souza    บ Data ณ  30/11/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina impressใo de etiquetas testeiras com imagem          ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


USER FUNCTION ณDTI137()
    private cAcesso := Repl(" ",10)
     
    DEFINE DIALOG oMainWnd TITLE "Exemplo TMSPrinter" FROM 180,180 TO 550,700 PIXEL 
        // Monta objeto para impressใo 
        oPrint := TMSPrinter():New("Exemplo TMSPrinter") 
        oPrint:SetPortrait() 
        oPrint:Setup()    
        oPrint:StartPage()                 
        oFont1 := TFont():New('Courier new',,-18,.T.) 
        oPrint:Say( 10,10,"Flavio Lindo",oFont1,1400,CLR_HRED ) 
        oPrint:SayBitmap( 100,200,"C:\Dir\images.bmp",400,400 )
        oPrint:Line( 130,10,130,900 )
        oPrint:Box( 130,10,600,900 )   
        oBrush1 := TBrush():New( , CLR_YELLOW ) 
        oPrint:FillRect( {100, 10, 200, 200}, oBrush1 ) 
        oBrush1:End()
        // Visualiza a impressใo 
        oPrint:EndPage()      
        oPrint:Preview() 
    ACTIVATE DIALOG oMainWnd CENTERED
RETURN




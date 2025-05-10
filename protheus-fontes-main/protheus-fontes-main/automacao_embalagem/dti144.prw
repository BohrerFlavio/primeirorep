#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI128  º Autor ³ Flávio Bohrer Flôres º Data ³  24/10/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Etiqueta de Porcentagem de Gordura   Raio X   º±±
±±º          ³ 	rotina adaptada para reimpressão da etiqueta de Carne     º±±
±±º          ³  Dia 28/02/22                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Equipamento de Raio X                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function dti144()

        valor1 	 := Space(10) // codigo da Caixa
        campoA   := Space(10)  //campo do codigo do produto
        valor2 	 := Space(40) //Descrição do corte

        DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA % Carne "
        //vinculação dos campos com os valores

        @ 01,01 SAY "Cod.Caixa:" of telaimp
        @ 02,01 SAY "Produto:" of telaimp

      
        @ 01,08 MSGET campoA VAR valor1 SIZE 30,10 OF telaimp 
        @ 02,08 SAY valor2 of telaimp

        @ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action Imprime(valor1)
        @ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()

        
        ACTIVATE MSDIALOG telaimp CENTERED


Return


Static Function Imprime(_cControl)
	
       /* Verificar se caixa gravou  na SZ8 ou na ZAS      */
        
        SZ8->(DbSetOrder(3))
	ZAS->(DbSetOrder(1))		
        if  SZ8->(DbSeek(xfilial('SZ8')+alltrim(_cControl))) 
                //alert('Linha 54 - SZ8')
                Processa({||U_GJF111W(alltrim(_cControl),'SZ8') },"IMPRESSAO DE PRE-ETIQUETA de % de Gordura","Realizando envio à impressora...")
        elseif ZAS->(DbSeek(xfilial('ZAS')+alltrim(_cControl)))
                //alert('Linha 57 - ZAS')
                Processa({||U_GJF111w(alltrim(_cControl),'ZAS') },"IMPRESSAO DE PRE-ETIQUETA de % de Gordura","Realizando envio à impressora...")
        Endif                        
	

return


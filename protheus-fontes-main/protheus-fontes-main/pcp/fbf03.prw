#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fbf03   º Autor ³ Flávio Bohrer Flores º Data ³  25/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Tabelas Nutricionais para etiqueta Espanhol    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa   Importação para o Chile                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF03()

	dbselectarea('ZZ7')
	dbsetorder(1)

	campoA  := '      '  //campo do codigo do produto
	campoB  := '        ' //campo da data da produção
	campoB_1:= '        ' // Data do Abate
	campoC 	:= '                                      '  //campo da descrição do corte Espanhol
	campoD 	:= 000    // Quantidades de Etiquetas
	campoE 	:= '      '   	//Lote
	campoF 	:= {" ","C","V","U"}// Tipificacao
	campoG 	:= {" ","ENFRIADO","CONGELADO"}  // Cong. Resfriago

	valor1 	:= '      ' 	//codigo do produto
	valor2 	:= date()   	//data de produção
	valor3  := date()     	//data do abate
	valor4 	:= '                   ' //Descrição do corte
	valor5 	:= 000     //Quantidade de etiqueta
	valor6 	:='      '// Lote
	valor7  :=' '// Tipificacao
	valor8  :='         ' // Cong. Resfr

	DEFINE MSDIALOG telaimp FROM 0,0 TO 450,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA"
	//vinculação dos campos com os valores

	@ 01,01 SAY "Produto:" of telaimp
	@ 02,01 SAY "Data Produção:" of telaimp
	@ 03,01 SAY "Data do Abate:" of telaimp
	@ 04,01 SAY "Descrição Corte:" of telaimp
	@ 05,01 SAY "Quant. Etiq.:" of telaimp
	@ 06,01 SAY "Lote:" of telaimp
	@ 07,01 SAY "Tipificacao:" of telaimp
	@ 08,01 SAY "Cong./Resfr.:" of telaimp

	@ 01,08 MSGET campoA   VAR valor1    SIZE 20,10  F3 'ZZ7' OF telaimp VALID iif(!existcpo('ZZ7'),fbf01clear(),.t.)// Produto
	@ 02,08 MSGET campoB   VAR valor2    SIZE 40,10  OF telaimp                    // data producao
	@ 03,08 MSGET campoB_1 VAR valor3    SIZE 40,10  OF telaimp                    // data abate
	@ 04,08 MSGET campoC   VAR valor4    SIZE 100,10 OF telaimp picture '@!'       //descricao corte
	@ 05,08 MSGET campoD   VAR valor5    SIZE 20,10  OF telaimp  picture '@E 999'  // quant etiqueta
	@ 06,08 MSGET campoE   VAR valor6    SIZE 20,10  OF telaimp picture '@E 999999'// LOTE*************
	@ 07,08 COMBOBOX valor7 items campoF SIZE 20,08  OF telaimp                    // Categoria*****************************
	@ 08,08 COMBOBOX valor8 items campoG SIZE 47,08  OF telaimp                    // Especie

	@ 200,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action fbf01etq()
	@ 200,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	campoA:bLostFocus := {|| fbf01prc() }
	ACTIVATE MSDIALOG telaimp CENTERED

return


static function fbf01prc()
	ZZ7->(dbsetorder(1))
	if ZZ7->(dbseek(xfilial('ZZ7')+valor1))
		valor4 := ZZ7->ZZ7_CORTEE
	endif
	telaimp:refresh()
return

static function fbf01clear()
	valor1   := '      '
	valor2   := date()
	valor3   :=date()
	valor4   := '                    '
	valor5   :=000
	valor6   := '      '
	valor7   :=' '
	valor8   :='         '
	telaimp:refresh()

return

static Function fbf01etq() // refazer..????????????????????
	if empty(valor1) .or. empty(valor2) .or. empty(valor3) .or. empty(valor4) .or. empty(valor5);
	.or. empty(valor6)
		Alert('Campos em branco!')
		return
	endif
	ZZ7->(dbsetorder(1))
	ZZ7->(dbseek(xfilial('ZZ7')+valor1))

	MSCBPRINTER("S600","LPT1")
	MSCBCHKSTATUS(.t.)
	MSCBBEGIN(valor5,6,15)  			 // Usar variavel no primeiro campo, para a quantidade de etiquetas
	dtVALID := valor2+ZZ7->ZZ7_DVALID // Data de validade

	tipo           := valor8
	fonte1         :="35,30"
	fonte2         :="21,20"
	fData          :="20,20"
	fData2         :="25,28"
	fonte4         :="21,15"
	fonte5         :="20,15"
	fonte6         :="58,60"
	fonte7         :="20,18"
	fontegraus     :="25,30"
	// 1º BOX
	MSCBBOX(6,4,60,21,5)
	MSCBSAY(8,6,ZZ7->ZZ7_DESCE,"N","0",fonte1)  	// GRUPO
	MSCBSAY(8,11,ZZ7->ZZ7_CORTEE,"N","0",fonte1) //Corte Espanhol
	MSCBSAY(8,16,valor4,"N","0",fonte1) 			// Descricao corte

	//Datas
	MSCBSAY(8,25,"FECHA DE BENEFICIO","N","0",fData) //Data do abate
	MSCBSAY(10,29,substr(dtos(valor3),7,2)+'/'+substr(dtos(valor3),5,2)+'/'+substr(dtos(valor3),3,2),"N","0",fData2)
	MSCBBOX(6,28,30,33,3)
	MSCBSAY(35,25,"FECHA DE PRODUTO","N","0",fData) //Data da producao
	MSCBSAY(38,29,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"N","0",fData2)
	MSCBBOX(33,28,60,33,3)
	MSCBSAY(8,34,"FECHA DE VECTO","N","0",fData) //Data do vencimento
	MSCBSAY(10,38,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"N","0",fData2)
	MSCBBOX(6,37,30,42,3)
	MSCBSAY(38,34,"LOTE NUMERO","N","0",fData) //Lote
	MSCBSAY(40,38,valor6,"N","0",fData2)
	MSCBBOX(33,37,60,42,3)

	/* Avisos SIF e Inf
	88 congelado
	87 resfriado
	*/
	MSCBBOX(6,45,60,49,3)
	MSCBSAY(8,46,'Uso autorizado pelo SIF/DIPOA Sob N',"N","0",fonte2)
	if tipo=='ENFRIADO'
		MSCBSAY(47,46,'0087',"N","0",fonte2)
	else
		MSCBSAY(47,46,'0088',"N","0",fonte2)
	endif
	MSCBSAY(52,46,'/1733',"N","0",fonte2)
	MSCBBOX(6,52,60,56,3)
	MSCBSAY(8,53,'INFORMACION NUTRICIONAL DE CARNE FRESCA POR CADA 100 Gr.',"N","0",fonte4)

	//Outro BOX das medidas
	//1º Linha
	MSCBBOX(6,59,60,85,5)
	MSCBSAY(7,61,'ENERGIA',"N","0",fonte5)
	MSCBSAY(24,61,ZZ7->ZZ7_ENERGI,"N","0",fonte7)
	MSCBSAY(29,61,'Kcal',"N","0",fonte5)
	MSCBSAY(33,61,'GRASA MONO-INSAT.',"N","0",fonte5)
	MSCBSAY(51,61,ZZ7->ZZ7_MNIN,"N","0",fonte7)
	MSCBSAY(57,61,'gr',"N","0",fonte5)

	//2º Linha
	MSCBSAY(7,65,'PROTEINA',"N","0",fonte5)
	MSCBSAY(24,65,ZZ7->ZZ7_PROTEE,"N","0",fonte7)
	MSCBSAY(29,65,'Kcal',"N","0",fonte5)
	MSCBSAY(33,65,'GRASA POLI-INSAT.',"N","0",fonte5)
	MSCBSAY(51,65,ZZ7->ZZ7_GRAPI,"N","0",fonte7)
	MSCBSAY(57,65,'gr',"N","0",fonte5)

	//3º Linha
	MSCBSAY(7,69,'LIPIDIOS',"N","0",fonte5)
	MSCBSAY(24,69,ZZ7->ZZ7_LIPID,"N","0",fonte7)
	MSCBSAY(29,69,'Kcal',"N","0",fonte5)
	MSCBSAY(33,69,'AC GRASOS TRANS.',"N","0",fonte5)
	MSCBSAY(51,69,ZZ7->ZZ7_ACGTR,"N","0",fonte7)
	MSCBSAY(57,69,'gr',"N","0",fonte5)

	//4º Linha
	MSCBSAY(7,73,'COLESTEROL',"N","0",fonte5)
	MSCBSAY(24,73,ZZ7->ZZ7_COLEXP,"N","0",fonte7)
	MSCBSAY(29,73,'mg',"N","0",fonte5)
	MSCBSAY(33,73,'SODIO',"N","0",fonte5)
	MSCBSAY(51,73,ZZ7->ZZ7_SODIOE,"N","0",fonte7)
	MSCBSAY(57,73,'gr',"N","0",fonte5)

	//5º Linha
	MSCBSAY(7,77,'CARBOHIDRATOS',"N","0",fonte5)
	MSCBSAY(24,77,ZZ7->ZZ7_CARBE,"N","0",fonte7)
	MSCBSAY(29,77,'gr',"N","0",fonte5)
	//6º Linha
	MSCBSAY(7,81,'GRASAS SATURADAS',"N","0",fonte5)
	MSCBSAY(24,81,ZZ7->ZZ7_GSATU,"N","0",fonte7)
	MSCBSAY(29,81,'gr',"N","0",fonte5)
	MSCBSAY(42,78,valor7,"N","0",fonte6)   //categoria
	MSCBBOX(38,77,50,85,3)

	MSCBBOX(6,87,60,93,3) // Se resfriada ou congelada
	if tipo == 'ENFRIADO'
		MSCBSAY(23,88,'ENFRIADO 0',"N","0",fonte1)
		MSCBSAY(42,87,'o',"N","0",fontegraus)
	endif
	if tipo == 'CONGELADO'
		MSCBSAY(22,88,'CONGELADO -18',"N","0",fonte1)
		MSCBSAY(49,87,'o',"N","0",fontegraus)
	endif
	MSCBEND()
	MSCBCLOSEPRINTER()
	fbf01clear()
	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return

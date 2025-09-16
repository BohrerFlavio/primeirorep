#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fbf01   º Autor ³ Flávio Bohrer Flores º Data ³  23/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de tiqueta Chile                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desossa                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FBF15()

	dbselectarea('ZZ7')
	dbsetorder(1)

	campoA 	:= {"MIOLO DA PALETA","PEIXINHO","CAPA DE PALETA","MIOLO DO ACEM","CAPA DO ACEM","RAQUETE","PEITO"}	//CORTE PORTUGUES
	campoB  := '          '    								//DATA ABATE
	campoC  := '          '  			   					//DATA PRODUÇAO DESOSSA
	campoD 	:= 000                        				// QUANTIDADE
	campoE 	:= {"V","C","U","N","O"}					//Classificação
	campoF 	:= {"CONGELADO","ENFRIADO 0º"}  				// ARMAZENAMENTO							

	valor1 	:= '     							'  //CORTE PORTUGUES
	valor2 	:= date(10)   	//data de abate
	valor3 	:= date(10) 		//data de produção Desossa
	valor4 	:= 000     //Quantidade de etiqueta
	valor5	:= ' '      // Classificação chile  
	valor6	:= '          '  // Armazenamento


	DEFINE MSDIALOG telaimp FROM 0,0 TO 310,350 PIXEL TITLE "IMPRESSAO DE ETIQUETA INTERNA CHILE"
	//vinculação dos campos com os valores

	//@ 01,01 SAY "Corte Espanhol:" of telaimp
	@ 01,01 SAY "Corte Portugues:" of telaimp
	@ 02,01 SAY "Data Abate:" of telaimp  // 				igual ao sexo
	@ 03,01 SAY "Data Produção:" of telaimp
	@ 04,01 SAY "Quant. Etiq.:" of telaimp
	@ 05,01 SAY "Class. Dentição:" of telaimp
	@ 06,01 SAY "Armazenamento:" of telaimp


	@ 01,08 COMBOBOX valor1 items campoA SIZE 65,08 OF telaimp    			//corte da carne
	@ 02,08 MSGET campoB VAR valor2 SIZE 42,10  OF telaimp					// data Abate
	@ 03,08 MSGET campoC VAR valor3 SIZE 42,10  OF telaimp					// data producao  Desossa
	@ 04,08 MSGET campoD VAR valor4 SIZE 20,10  OF telaimp  picture '@E 999'// quant etiqueta
	@ 05,08 COMBOBOX valor5 items campoE SIZE 18,08 OF telaimp      		//Classificação  Chile
	@ 06,08 COMBOBOX valor6 items campoF SIZE 45,08 OF telaimp      		//ARMAZENAMENTO


	@ 120,25 BUTTON btn1 PROMPT "Imprimir" SIZE 50,15 OF telaimp  pixel action fbf15etq()
	@ 120,80 BUTTON btn2 PROMPT "Fechar" SIZE 50,15 OF telaimp  pixel action telaimp:end()
	ACTIVATE MSDIALOG telaimp CENTERED

return

static function fbf15clear()
	valor1   := '      '        // CORTE
	valor2   := date() 			//ABATE
	valor3   := date() 			// PRODUCAO DESOSSA
	valor4   := 000             //QUANTIDADE
	valor5   := '     '         //CHASSIFICAÇÃO CHILE
	valor6   := '     '         //ARMAZENAMENTO

	telaimp:refresh()
return

static Function fbf15etq()     

	MSCBPRINTER('S600','LPT1')
	MSCBCHKSTATUS(.t.)
	//MSCBBEGIN(valor4,6,15)  // Usar variavel no primeiro campo, para a quantidade de etiquetas
	MSCBBEGIN(valor4,6,15)

	_vResfriado		:= 90
	_vCongelado		:= 360
	_cCorteesp		:= '                                '
	IF valor6 = 'CONGELADO' 
		_dvalid := _vCongelado
	elseif valor6 = 'ENFRIADO 0º'
		_dvalid := _vResfriado
	endif  

	_dtVALID := valor3+_dvalid // Data de validade
	f01     :="35,32"
	f02		:="16,20" 
	f03     :="28,32"  // DAS DATAS   
	f04     :="60,80"
	f05		:="45,50"
	f06		:="21,19"  
	f07		:="20,15"

	MSCBBOX(1,10,56,25,4)
	MSCBSAY(3,12,"CARNE DE VACUNO SIN HUESO","N","0",f01)
	t:=len(campoA)
	pos:=22-t

	MSCBSAY(pos,21,alltrim(valor1),"N","0",f01)
	do case                                                       
		case valor1 = 'MIOLO DA PALETA' 
		_cCorteesp := 'POSTA DE PALETA'
		case valor1 = 'PEIXINHO'
		_cCorteesp := 'CHOCLILLO'
		case valor1 = 'CAPA DE PALETA'    		                                  
		_cCorteesp := 'ASADO DEL CARNICERO'		
		case valor1 = 'MIOLO DO ACEM'     
		_cCorteesp := 'HUACHALOMO'	
		case valor1 = 'CAPA DO ACEM'
		_cCorteesp := 'SOBRECOSTILLA'			
		case valor1 = 'RAQUETE'					
		_cCorteesp := 'PUNTA PALETA'   
		case valor1 = 'PEITO'					
		_cCorteesp := 'TAPAPECHO'			
	endcase 
	MSCBSAY(pos,17,alltrim(_cCorteesp),"N","0",f01) // nome do corte      

	MSCBSAY(2,30,"FECHA DE BENEFICIO","N","0",f02)
	MSCBBOX(1,32,26,37,3)
	MSCBSAY(6,33,substr(dtos(valor2),7,2)+'/'+substr(dtos(valor2),5,2)+'/'+substr(dtos(valor2),3,2),"N","0",f03) //Data da producao
	dtVALID := valor3+60 // Data de validade
	MSCBSAY(29,30,"FECHA DE PRODUTO","N","0",f02)
	MSCBBOX(28,32,56,37,3)
	MSCBSAY(30,33,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"N","0",f03) //Data validade
	MSCBSAY(5,38,"FECHA DE VCTO","N","0",f02)
	MSCBBOX(1,40,26,45,3)
	MSCBSAY(6,41,substr(dtos(dtVALID),7,2)+'/'+substr(dtos(dtVALID),5,2)+'/'+substr(dtos(dtVALID),3,2),"N","0",f03) //Data validade 
	MSCBSAY(34,38,"LOTE NUMERO","N","0",f02)
	MSCBBOX(28,40,56,45,3)
	MSCBSAY(38,41,"15","N","0",f03) //Data validade 
	MSCBBOX(1,46,56,51,3)
	MSCBSAY(3,47,"USO AUTORIZADO PELO SIF/DIPOA SOB N 087/1733","N","0",f06) //USO AUTORIZADO
	MSCBBOX(1,52,56,57,3)
	MSCBSAY(3,53,"INFORMACION NUTRICIONAL DE CARNE FRESCA POR CADA 100 Gr.","N","0",f07) //USO AUTORIZADO
	//TABELA NUTRICIONAL
	MSCBBOX(1,58,56,82,3)

	MSCBBOX(34,74,44,82,4)
	MSCBSAY(36,75,valor5,"N","0",f04) // classificação dentição 
	MSCBBOX(1,84,56,92,4)
	MSCBSAY(14,86,valor6,"N","0",f05)
	//MSCBSAY(21,24,valor6,"B","0",fonteNomeCorte1)// Sexo
	//MSCBSAY(21,13,alltrim(valor4)+'g',"B","0",fonteNomeCorte1)//tara
	//MSCBSAY(25,9,'REGISTRO NO MINISTERIO DA AGRICULTURA/SIF/DIPOA SOB Nr '+ZZ7->ZZ7_MSIF,"B","0",fonteInscSIF)
	/*
	//Box Grande
	MSCBBOX(28,6,55,70,4)
	//1º Titulo
	MSCBBOX(31,6,31,70,3)
	MSCBSAY(29,24,'INFORMACOES NUTRICIONAIS',"B","0",fonteInfNutri1)
	//2º Linha
	MSCBBOX(34,6,34,70,3)
	MSCBSAY(32,21,'Porcao de 100g de parte comestivel',"B","0",fonteInfNutri1)

	//3º Linha
	MSCBSAY(35,49,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBLineH(34,45,37,3,"B")//1ª Barra vertical
	MSCBSAY(35,38,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBLineH(34,37,37,3,"B")//2ª Barra vertical
	MSCBSAY(35,16,'Quantidade por Porcao',"B","0",fonteInfNutri2)
	MSCBLineH(34,15,37,3,"B")   //3ª barra vertical   (y1,x1,x2)
	MSCBSAY(35,8,'%VD(*)',"B","0",fonteInfNutri2)
	MSCBLineV(37,6,70,3,"B")// essa linha esta fazendo a horizontal (Y,X1,X2)

	//4ª Linha
	MSCBSAY(38,57,'Valor calorico',"B","0",fonteInfNutri2)
	MSCBLineH(37,55,40,3,"B")//1ª Barra vertical
	//MSCBSAY(38,46,ZZ7->ZZ7_CALQTP,"B","0",fonteInfNutri2)
	MSCBLineH(37,45,40,3,"B")//2ª Barra vertical
	//MSCBSAY(38,39,ZZ7->ZZ7_CALVD,"B","0",fonteInfNutri2)
	MSCBLineH(37,37,40,3,"B")//3ª Barra vertical
	MSCBSAY(38,26,'Colesterol',"B","0",fonteInfNutri2)
	MSCBLineH(37,24,40,3,"B")//4ª Barra vertical
	//MSCBSAY(38,18,ZZ7->ZZ7_COLQTP,"B","0",fonteInfNutri2)
	MSCBLineH(37,15,40,3,"B")//5ª Barra vertical
	//MSCBSAY(38,9,ZZ7->ZZ7_COLVD,"B","0",fonteInfNutri2)
	MSCBLineV(40,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//5ª Linha
	MSCBSAY(41,58,'Carboidratos',"B","0",fonteInfNutri2)
	MSCBLineH(40,55,43,3,"B")//1ª Barra vertical
	//MSCBSAY(41,47,ZZ7->ZZ7_CARQTP,"B","0",fonteNutri4)
	MSCBLineH(40,45,43,3,"B")//2ª Barra vertical
	//MSCBSAY(41,39,ZZ7->ZZ7_CARVD,"B","0",fonteInfNutri2)
	MSCBLineH(40,37,43,3,"B")//3ª Barra vertical
	MSCBSAY(41,25,'Fibra Alim.',"B","0",fonteInfNutri2)
	MSCBLineH(40,24,43,3,"B")//4ª Barra vertical
	//MSCBSAY(41,18,ZZ7->ZZ7_FIAQTP,"B","0",fonteNutri4)
	MSCBLineH(40,15,43,3,"B")//5ª Barra vertical
	//MSCBSAY(41,9,ZZ7->ZZ7_FIAVD,"B","0",fonteInfNutri2)
	MSCBLineV(43,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)

	//6ª Linha
	MSCBSAY(44,61,'Proteinas',"B","0",fonteInfNutri2)
	MSCBLineH(43,55,46,3,"B")//1ª Barra vertical
	//MSCBSAY(44,48,ZZ7->ZZ7_PROQTP,"B","0",fonteInfNutri2)
	MSCBLineH(43,45,46,3,"B")//2ª Barra vertical
	//MSCBSAY(44,39,ZZ7->ZZ7_PROVD,"B","0",fonteInfNutri2)
	MSCBLineH(43,37,46,3,"B")//3ª Barra vertical
	MSCBSAY(44,30,'Calcio',"B","0",fonteInfNutri2)
	MSCBLineH(43,24,46,3,"B")//4ª Barra vertical

	if alltrim(ZZ7->ZZ7_CACQTP) == 'Qtd n signif'
	MSCBSAY(44,16,ZZ7->ZZ7_CACQTP,"B","0",fonte3)
	else
	MSCBSAY(44,17,ZZ7->ZZ7_CACQTP,"B","0",fonteInfNutri2) //numero de rastro
	Endif
	MSCBLineH(43,15,46,3,"B")//5ª Barra vertical
	if alltrim(ZZ7->ZZ7_CACVD) == 'Qtd n signif'
	MSCBSAY(44,7,ZZ7->ZZ7_CACVD,"B","0",fonte3)
	else
	MSCBSAY(44,8,ZZ7->ZZ7_CACVD,"B","0",fonteInfNutri2) //numero de rastro
	Endif
	MSCBLineV(46,6,70,3,"B")

	//7ª Linha
	MSCBSAY(47,55,'Gorduras Totais',"B","0",fonteInfNutri2)
	MSCBLineH(46,55,49,3,"B")//1ª Barra vertical
	//MSCBSAY(47,48,ZZ7->ZZ7_GTQTP,"B","0",fonteInfNutri2)
	MSCBLineH(46,45,49,3,"B")//2ª Barra vertical
	//MSCBSAY(47,39,ZZ7->ZZ7_GTVD,"B","0",fonteInfNutri2)
	MSCBLineH(46,37,49,3,"B")//3ª Barra vertical
	MSCBSAY(47,31,'Ferro',"B","0",fonteInfNutri2)
	MSCBLineH(46,24,49,3,"B")//4ª Barra vertical
	//MSCBSAY(47,18,ZZ7->ZZ7_FERQTP,"B","0",fonteInfNutri2)
	MSCBLineH(46,15,49,3,"B")//5ª Barra vertical
	//MSCBSAY(47,9,ZZ7->ZZ7_FERVD,"B","0",fonteInfNutri2)
	MSCBLineV(49,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	//8ª Linha
	MSCBSAY(50,55,'Gorduras Satur.',"B","0",fonteInfNutri2)
	MSCBLineH(49,55,52,3,"B")//1ª Barra vertical
	//MSCBSAY(50,48,ZZ7->ZZ7_GSQTP,"B","0",fonteInfNutri2)
	MSCBLineH(49,45,52,3,"B")//2ª Barra vertical
	//MSCBSAY(50,39,ZZ7->ZZ7_GSVD,"B","0",fonteInfNutri2)
	MSCBLineH(49,37,52,3,"B")//3ª Barra vertical
	MSCBSAY(50,30,'Sodio',"B","0",fonteInfNutri2)
	MSCBLineH(49,24,52,3,"B")//4ª Barra vertical
	//MSCBSAY(50,18,ZZ7->ZZ7_SODQTP,"B","0",fonteInfNutri2)
	MSCBLineH(49,15,52,3,"B")//5ª Barra vertical
	//MSCBSAY(50,9,ZZ7->ZZ7_SODVD,"B","0",fonteInfNutri2)
	MSCBLineV(52,6,70,3,"B")// essa linha esta fazendo a banse horizontal (Y,X1,X2)
	//9ª Linha
	MSCBSAY(53,11,'(*)VALORES DIARIOS DE REFERENCIA COM A BASE EM UMA DIETA DE 2.500 CAL',"B","0",fontelinha9)
	*/
	MSCBEND()
	MSCBCLOSEPRINTER()
	fbf15clear()


	msgbox('Impressão de Etiquetas em Andamento!','Impressão','INFO')

return

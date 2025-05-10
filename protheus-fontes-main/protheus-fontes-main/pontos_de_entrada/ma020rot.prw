#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MA020ROT
Ponto Entrada no início, antes da execução da Mbrowse dos Fornecedores. Utilizado para adicionar mais opções de menu (no aRotina).
@author     Evandro
@since      04/06/2020
@return     aRet(Vetor) - Deve retornar um Array contendo as novas opções no menu na estrutura.
@obs        N/A
/*/

User Function MA020ROT()

	Local _aRotUser := {}	//Define Array contendo as Rotinas a executar do programa     
	Local _nUser  := GetMV('SI_LUC')
	// ----------- Elementos contidos por dimensao ------------    
	// 1. Nome a aparecer no cabecalho                             
	// 2. Nome da Rotina associada                                 
	// 3. Usado pela rotina                                        
	// 4. Tipo de Transacao a ser efetuada                         
	//    1 - Pesquisa e Posiciona em um Banco de Dados            
	//    2 - Simplesmente Mostra os Campos                        
	//    3 - Inclui registros no Bancos de Dados                  
	//    4 - Altera o registro corrente                           
	//    5 - Remove o registro corrente do Banco de Dados         
	//    6 - Altera determinados campos sem incluir novos Regs     
	/*
	If AllTrim(UPPER(cUserName)) == UPPER("gianice.weber")    .Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("henrique.andrade") .Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("estagiario.compras") .Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("jose.rodrigo")
	*/	
	//alert('Usuario logado->'+AllTrim(UPPER(cUserName))+ 'Linha 33-> Users cadastrados->'+_nUser)
	If AllTrim(UPPER(cUserName)) $ AllTrim(UPPER(_nUser))

		AAdd( _aRotUser, { OemToAnsi("Segmentos x Fornecedor p/ Cotação"), "VIEWDEF.STIA022", 0, 4 } )	// Rotina MVC executada pelo fonte STIA022.PRW
	
	ElseIf AllTrim(UPPER(cUserName)) == UPPER("fabiane.pozzer") .Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("lucia.cruz")			.Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("karine.vargas")		.Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("cristiane.trindade")	.Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("vanessa.roque")		.Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("clailton.soares")	.Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("elivelton.alves")	.Or. ;
	   AllTrim(UPPER(cUserName)) == UPPER("everton.souza")
	
		AAdd( _aRotUser, { OemToAnsi("Usuários x Pre-Nota"), 			   "VIEWDEF.STIA021", 0, 4 } )	// Rotina MVC executada pelo fonte STIA021.PRW

	ElseIf AllTrim(UPPER(cUserName)) == UPPER("Administrador")
	
		AAdd( _aRotUser, { OemToAnsi("Segmentos x Fornecedor p/ Cotação"), "VIEWDEF.STIA022", 0, 4 } )	// Rotina MVC executada pelo fonte STIA022.PRW
		AAdd( _aRotUser, { OemToAnsi("Usuários x Pre-Nota"), 			   "VIEWDEF.STIA021", 0, 4 } )	// Rotina MVC executada pelo fonte STIA021.PRW
	
	Endif


	
Return(_aRotUser)

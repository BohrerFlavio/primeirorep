#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
User Function MaFisRur()  
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณMAFISRUR  บAutor  ณGiuliano Forgiarini บ Data ณ  12/12/13   บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDesc.     ณ  Ponto de Entrada para definir aliquota de FUNRURAL conformeฑฑ
	ฑฑบ          ณ  cadastro de fornecedores                                  บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ contabilidade, Compra de Gado                              บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	*/
	Local _cTES    := PARAMIXB[1] //Codigo do TES
	Local _cProd   := PARAMIXB[2] //codigo do produto
	Local _cCliFor := PARAMIXB[3] //C = cliente / F = Fornecedor
	Local _cSaiEnt := PARAMIXB[4] //S = Saida / E = Entrada
	Local _cCodCF  := PARAMIXB[5] //Codigo do cliente ou fornecedor   
	Local _Loja    := PARAMIXB[6] //Loja
	Local _cTipP   := PARAMIXB[7] //Tipo pessoa
	Local _nAliq   := PARAMIXB[8] //Aliquota atual que tแ no parametro MV_CONTSOC 
	Local _PosEmp  := ''

	if FunName() $ 'MATA103' .Or. FunName() $ 'STI_RG06'
		if cEmpAnt <> '08'       
			if (_cCliFor = 'F') .and. (_cTipP = 'L')
				_PosEmp := fBuscaCPO('SA2',1,xfilial('SA2')+_cCodCF + _Loja,'A2_POSEMP')      
				if _PosEmp = '2'
					//_nAliq := 1.5 //2.3 -- Alterado para nova regra E-social/Reimp 05/06/2018 Wellington
					_nAliq := 1.3 //2.3
				elseif _PosEmp = '1'
					_nAliq := 0
				endif
				
			endif
		else
			if (_cCliFor = 'F') .and. (_cTipP = 'L')
				//_nAliq := 1.5 //2.3 -- Alterado para nova regra E-social/Reimp 05/06/2018 Wellington
				_nAliq := 1.3 //2.3
			endif
		endif	
	endif
	
	
Return _nAliq

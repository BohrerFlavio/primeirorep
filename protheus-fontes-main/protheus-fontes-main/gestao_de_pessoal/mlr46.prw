#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMLR46     บAutor  ณ Mauricio Roehrs    บ Data ณ  11/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa desenvolvido com a finalidade de calcular a verba บฑฑ
ฑฑบ          ณ  de adicional de tempo de servi็o sobre horas extras       บฑฑ
ฑฑบ          ณ  adicionar na sequencia 764 do roteiro				           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function MLR46()


	_nVlAdcHr  := 0 //valor de adicional de tempo de servico por hora  
	_nVlHrs110 := 0 //valor do adicional noturo
	_nVlHrs111 := 0 //valor do adicional sobre as horas extras 60% 
	_nVlHrs113 := 0 //valor do adicional sobre as horas extras 100%   
	_nVlHrs272 := 0 //valor do acordo do sabado feriado horas extras 60%   
	_nVlHrs197 := 0 //valor do acordo horas extras 60%   
	_nVlHrs210 := 0 //valor do adicional norturno 30%                      
	_nVlHrs136 := 0 //valor do adicional sobre as horas extras 50%(transportadora) 


	if cEmpAnt <> '07' // se for frigorifico ou graxaria
		if fBuscaPd("107") > 0 .and. fBuscaPd("110,111,113,272,197,210") > 0

			//pos dissidio
			//_nVlAdcHr1 := (((((INT(((DDATABASE-SRA->RA_ADMISSA)/365)/5))*4)/100) * (salmes+fbuscapd("185")))/30)
			if cFilAnt = '01'
				_nVlAdcHr1 := (((((INT(((DDATABASE-SRA->RA_ADMISSA)/365)/5))*4)/100) * (salmes)))//se for filial 01				
			else
				_nVlAdcHr1 := (((((INT(((DDATABASE-SRA->RA_ADMISSA)/365)/5))*5)/100) * (salmes)))				
			endif   

			_nVlAdcHr := _nVlAdcHr1 / SRA->RA_HRSMES			                                                      

			//_nVlAdcHr  := fBuscaPd("107") / SRA->RA_HRSMES

			_nVlHrs110 := (fBuscaPd("110","H") * _nVlAdcHr) * 0.2 //adicional noturno 20%

			_nVlHrs111 := (fBuscaPd("111","H") * _nVlAdcHr) * 1.6 //calcula 60%

			_nVlHrs113 := (fBuscaPd("113","H") * _nVlAdcHr) * 2	//calcula 100%

			_nVlHrs272 := (fBuscaPd("272","H") * _nVlAdcHr) * 1.6 //calcula 60%

			_nVlHrs197 := (fBuscaPd("197","H") * _nVlAdcHr) * 1.6 //calcula 60%          

			_nVlHrs210 := (fBuscaPd("210","H") * _nVlAdcHr) * 0.3 //adicional noturno 30%(riogrande)

			fGeraVerba("227", _nVlHrs110 + _nVlHrs111 + _nVlHrs113 + _nVlHrs272 +_nVlHrs197 + _nVlHrs210)						

		endif
	elseif cEmpAnt == '07'//se for tranportadora
		if fBuscaPd("107") > 0 .and. fBuscaPd("110,136,113") > 0

			_nVlAdcHr1 := (((((INT(((DDATABASE-SRA->RA_ADMISSA)/365)/5))*5)/100) * (salmes)))				
			_nVlAdcHr := _nVlAdcHr1 / SRA->RA_HRSMES			                                                      

			//_nVlAdcHr  := fBuscaPd("107") / SRA->RA_HRSMES

			_nVlHrs110 := (fBuscaPd("110","H") * _nVlAdcHr) * 0.2 //adicional noturno

			_nVlHrs136 := (fBuscaPd("136","H") * _nVlAdcHr) * 1.5 //calcula 50%

			_nVlHrs113 := (fBuscaPd("113","H") * _nVlAdcHr) * 2	//calcula 100%

			fGeraVerba("227", _nVlHrs110 + _nVlHrs136 + _nVlHrs113)						

		endif	

	endif		   

return

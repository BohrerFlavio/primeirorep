#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*/
ฑฑบPrograma  ณDTI135     บ Autor ณMateus Escobarบ   Data ณ  25/11/2021    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Modelo Etiqueta para o fonte DTI136                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
/*/

User Function DTI135(_modelo,_porta,_ip,nP1)
_Fonte:= "300,180"


MSCBPRINTER('S600','IP',,,,,_Ip)
MSCBPRINTER(_modelo,_porta,,,,,_Ip)
MSCBCHKSTATUS(.f.)
MSCBBEGIN(1,6,40)

MSCBBOX(09,56,45,92,140,"B")                               //Box preto onde fica o cod. do produto
MSCBSAYMEMO(12,60,79,1,str(nP1),"N","0",_Fonte,.t.,"J")    //c๓digo do produto	
MSCBEND()

MSCBCLOSEPRINTER()

Return .t.

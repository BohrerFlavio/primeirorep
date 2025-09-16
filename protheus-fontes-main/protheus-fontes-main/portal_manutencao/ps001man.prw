#INCLUDE "apwebex.ch"

User Function PS001MAN()
	cHtml:= ""

	WEB EXTENDED INIT cHtml

	HTTPSESSION->cUSER:= ''
	HTTPSESSION->cPASS:= ''
	HTTPSESSION->cLOGO:= '<img src=imagens/logo2.jpg height=60 width=246>'
	HTTPSESSION->cEmp:= "01"
	HTTPSESSION->cFil:= "00"
	HTTPSESSION->cCC:= ""

	cHtml+= '<!DOCTYPE html>'
	cHtml+= '<html lang="pt-Br">'
	cHtml+= '  <head>'
	cHtml+= '    <meta charset="utf-8" />'
	cHtml+= '    <title>Portal manutencao</title>'
	cHtml+= '    <link rel="shortcut icon" href="http://www.primmeservices.com.br/primme/img/favicon.ico" type="image/x-icon"/>'
	cHtml+= '    <link rel="stylesheet" href="manutencao/css/bootstrap.min.css">'
	cHtml+= '    <link rel="stylesheet" href="manutencao/css/bootstrap-theme.min.css">'
	cHtml+= '    <link href="manutencao/css/dataTables.bootstrap.min.css" rel="stylesheet" type="text/css"/>'
	cHtml+= '    <link href="manutencao/css/select.dataTables.min.css" rel="stylesheet" type="text/css"/>'
	cHtml+= '  </head>'
	cHtml+= '  <body>'
	cHtml+= '    <style>'
	cHtml+= '      .modal-dialog {'
	cHtml+= '        padding: 0;'
	cHtml+= '      }'
	cHtml+= '      .modal-content {'
	cHtml+= '        border-radius: 0;'
	cHtml+= '      }'

	cHtml+= '    </style>'

	cHtml+= '    <script src="manutencao/js/jquery-1.11.1.min.js"></script>'
	cHtml+= '    <script src="manutencao/js/bootstrap.min.js"></script>'
	cHtml+= '    <script src="manutencao/js/jquery.mask.min.js"></script>'

	cHtml+= '    <script src="manutencao/js/jquery.dataTables.min.js"></script>'
	cHtml+= '    <script src="manutencao/js/dataTables.bootstrap.min.js"></script>'
	cHtml+= '    <script src="manutencao/js/dataTables.select.min.js"></script>'

	cHtml+= '    <script type="text/javascript">'
	cHtml+= '      document.body.style.zoom = "100%";'
	cHtml+= '      $(document).ready(function () {'

	cHtml+= "      $.ajax({"
	cHtml+= "             async: false,"
	cHtml+= "             method: 'POST',"
	cHtml+= "             url: 'u_ps100man.apw',"
	cHtml+= "           }).done(function(data){eval(data);});"

	cHtml+= '      });'
	cHtml+= '    </script>'

	cHtml+= '    <div id="psmain"></div>'
	cHtml+= '    <div id="psgetdados"></div>'
	cHtml+= '    <div id="psf3"></div>'
	cHtml+= '    <div id="psalert"></div>'

	cHtml+= '    </body>'
	cHtml+= '</html>'

	WEB EXTENDED END

Return cHtml

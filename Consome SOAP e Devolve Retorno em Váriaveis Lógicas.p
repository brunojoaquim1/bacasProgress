/* Declara‡Æo de bibliotecas externas 
** Lembrando que deve haver a declara‡Æo dos seguintes caminhos dentro do propath
** C:\OE117\gui\OpenEdge.Core.pl
** C:\OE117\gui\netlib\OpenEdge.Net.pl
** C:\OE117\gui\OpenEdge.BusinessLogic.pl
** C:\OE117\gui\OpenEdge.ServerAdmin.pl
*/

USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Net.HTTP.Lib.ClientLibraryBuilder.
USING OpenEdge.Net.URI.

/* Defini‡Æo de handles de controle */

DEFINE VARIABLE oRequest                 AS IHttpRequest                 NO-UNDO.
DEFINE VARIABLE oResponse                AS IHttpResponse                NO-UNDO.
DEFINE VARIABLE oURI                     AS URI                          NO-UNDO.
DEFINE VARIABLE oRequestBody             AS OpenEdge.Core.String         NO-UNDO.
DEFINE VARIABLE hXMLHandle               AS HANDLE                       NO-UNDO.
DEFINE VARIABLE lcXML                    AS LONGCHAR                     NO-UNDO.

//Variaveis de uso l¢gico dentro da estrutura do programa */

DEFINE VARIABLE i-uf                     AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE i-cnpj                   AS CHARACTER                    NO-UNDO.

ASSIGN i-uf = 'RS'.
ASSIGN i-cnpj = '89729867000196'. 


//Variav‚is declaradas aqui devem ser as que serÆo usada para a passagem de valor durante a leitura do XML

DEFINE VAR iCNPJ              AS CHAR.
DEFINE VAR iIE                AS CHAR.
DEFINE VAR iRAZAOSOCIAL       AS CHAR.
DEFINE VAR iREGIMEAPURACAO    AS CHAR.
DEFINE VAR iSITUACAO          AS CHAR .
DEFINE VAR iUF                AS CHAR.
DEFINE VAR iULTIMASITUACAO    AS CHAR.

DEFINE VAR iBAIRRO            AS CHAR.
DEFINE VAR iCEP               AS CHAR.
DEFINE VAR iCODIGOMUNICIPIO   AS CHAR.
DEFINE VAR iLOGRADOURO        AS CHAR.
DEFINE VAR iMUNICIPIO         AS CHAR.
DEFINE VAR iNUMERO            AS CHAR.


//Cria‡Æo do Envelope XML para o envio

oRequestBody =  NEW OpenEdge.Core.String(
 '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nfs="http://webservices.totvs.com.br/nfsebra.apw">'
+  '<soapenv:Header/>'
+  '<soapenv:Body>'
+     '<nfs:CONSULTACONTRIBUINTE>'
+        '<nfs:USERTOKEN>TOTVS</nfs:USERTOKEN>'
+        '<nfs:ID_ENT>000001</nfs:ID_ENT>'
+        '<nfs:UF>' + i-uf + '</nfs:UF>'
+        '<nfs:CNPJ>' + i-cnpj + '</nfs:CNPJ>'
+      '</nfs:CONSULTACONTRIBUINTE>'
+   '</soapenv:Body>'
+ '</soapenv:Envelope>'
).

                                
//Defini‡Æo dos parƒmetros de envio da requisi‡Æo SOAP

oURI = URI:Parse("http://srvtotvsdiv:8484/NFESBRA.apw").
oRequest = RequestBuilder:Post(oUri, oRequestBody)
                         :ContentType('text/xml;charset=UTF-8')
                         :AcceptAll()
                         :AddHeader('SOAPAction', 'http://webservices.totvs.com.br/nfsebra.apw/CONSULTACONTRIBUINTE';)
                         :Request.

oResponse = ClientBuilder:Build()
                         :Client:Execute(oRequest).

//TRATAMENTO DO RETORNO

IF oResponse:StatusCode <> 200 THEN
   DO:
    MESSAGE "http error: " oResponse:StatusCode VIEW-AS ALERT-BOX. 
    RETURN ERROR "Request Error: " + STRING(oResponse:StatusCode).
   END.
ELSE
  DO:
    hXMLHandle = CAST(oResponse:Entity,WidgetHandle):Value.
    hXMLHandle:SAVE('LONGCHAR',lcXML).
    MESSAGE STRING(lcXML) VIEW-AS ALERT-BOX. 
 END. 


RUN pi-le-retorno(lcXML).

// Esta procedure converte o longchar obtido no envio para um handle, ismiu‡ando a estrtutura do XML 

 procedure pi-le-retorno.
    DEFINE INPUT PARAM p-xml   AS LONGCHAR.
    DEFINE VARIABLE hDoc       AS HANDLE.
    DEFINE VARIABLE hRoot      AS HANDLE.
    
    CREATE X-DOCUMENT hDoc.
    CREATE X-NODEREF hRoot.

    hDoc:LOAD("longchar",p-xml,FALSE).
    
    hDoc:GET-DOCUMENT-ELEMENT(hRoot).
    
    run procura-dados-retorno(input hRoot).

    IF VALID-HANDLE(hDoc) THEN
        DELETE OBJECT hDoc.
    IF VALID-HANDLE(hRoot) THEN
        DELETE OBJECT hRoot.    
end procedure.

procedure procura-dados-retorno.

// Busca os valores das TAGS do XML 

    def input param pNode as handle.
    def var i-num-filhos as int no-undo.
    def var i-campo as int no-undo.

    def var haux as handle.
    def var hNode as handle.

    create x-noderef hNode.
    create x-noderef haux.

repeat i-num-filhos = 1 to pNode:num-children:        
    pNode:GET-CHILD(hNode, i-num-filhos).

    IF pNode:NAME = "IE" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iIE = haux:node-value.
    END.
    IF pNode:NAME = "CEP" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iCEP = haux:node-value.
    END.
    IF pNode:NAME = "CNPJ" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iCNPJ = haux:node-value.
    END.
    IF pNode:NAME = "RAZAOSOCIAL" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iRAZAOSOCIAL = haux:node-value.
    END.
    IF pNode:NAME = "REGIMEAPURACAO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iREGIMEAPURACAO = haux:node-value.
    END.
    IF pNode:NAME = "SITUACAO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iSITUACAO = haux:node-value.
    END.
    IF pNode:NAME = "UF" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iUF = haux:node-value.
    END.
    IF pNode:NAME = "ULTIMASITUACAO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iULTIMASITUACAO = haux:node-value.
    END.
    
    IF pNode:NAME = "BAIRRO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iBAIRRO = haux:node-value.
    END.
    IF pNode:NAME = "CEP" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iCEP = haux:node-value.
    END.
    IF pNode:NAME = "CODIGOMUNICIPIO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iCODIGOMUNICIPIO = haux:node-value.
    END.
    IF pNode:NAME = "LOGRADOURO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iLOGRADOURO = haux:node-value.
    END.
    IF pNode:NAME = "MUNICIPIO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iMUNICIPIO = haux:node-value.
    END.
    IF pNode:NAME = "NUMERO" THEN DO:
        pNode:GET-CHILD(haux, 1).
        ASSIGN iNUMERO = haux:node-value.
    END.


    if hNode:num-children > 0 
        then run procura-dados-retorno(hNode).
    end.

    if valid-handle(hNode) 
    then delete object hNode.
    if valid-handle(haux) 
    then delete object haux.

end procedure.


MESSAGE "CNPJ: "            iCNPJ             SKIP 
        "IE: "              iIE               SKIP            
        "RAZAOSOCIAL: "     iRAZAOSOCIAL      SKIP 
        "REGIMEAPURACAO: "  iREGIMEAPURACAO   SKIP    
        "SITUACAO: "        iSITUACAO         SKIP       
        "UF: "              iUF               SKIP              
        "ULTIMASITUACAO: "  iULTIMASITUACAO      
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

MESSAGE "BAIRRO: "            iBAIRRO       		SKIP         
		"CEP: "               iCEP            		SKIP
		"CODIGOMUNICIPIO: "   iCODIGOMUNICIPIO 	SKIP
		"LOGRADOURO: "        iLOGRADOURO     		SKIP
		"MUNICIPIO: "         iMUNICIPIO       	SKIP
		"NUMERO: "            iNUMERO 		
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

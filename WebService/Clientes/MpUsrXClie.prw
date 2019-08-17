#include 'protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} MpUsrXClie
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpUsrXClie
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New() constructor
	method GetUsrCli()							// Obtem Todos.
	method GetByUsr(cId)						// Obtem Todos Por Usuário.
	method GetByCli(cId)						// Obtem Todos Por Cliente.
	method PostUsrCli()							//
	method PostLibCli(nIdVend,nIdCli,lBlq)		//

endclass

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} new
Metodo construtor
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method new() class MpUsrXClie
	::cEntid	:= "usuarios_clientes"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetUsrCli
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method GetUsrCli() class MpUsrXClie
	Local oJson
	Local oRet	:= {}

	oRestUsrCli := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestUsrCli:setPath("")

	If oRestUsrCli:Get(aHeader)
		U_DH05A00L("usuarios_clientes","GET",oRestUsrCli:cHost,oRestUsrCli:cResult)

		If FWJsonDeserialize(oRestUsrCli:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetByUsr
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method GetByUsr(cId) class MpUsrXClie
	Local oJson
	Local oRet	:= {}

	If ValType(cId) == 'U'
		cId := ''
	ElseIf ValType(cId) == 'N'
		cId := cValToChar(cId)
	EndIf

	oRestUsrCli := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/usuario/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestUsrCli:setPath("")

	If oRestUsrCli:Get(aHeader)
		U_DH05A00L("usuarios_clientes","GET",oRestUsrCli:cHost,oRestUsrCli:cResult)

		If FWJsonDeserialize(oRestUsrCli:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetByCli
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method GetByCli(cId) class MpUsrXClie
	Local oJson
	Local oRet	:= {}

	If ValType(cId) == 'U'
		cId := ''
	ElseIf ValType(cId) == 'N'
		cId := cValToChar(cId)
	EndIf

	oRestUsrCli := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/cliente/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestUsrCli:setPath("")

	If oRestUsrCli:Get(aHeader)
		U_DH05A00L("usuarios_clientes","GET",oRestUsrCli:cHost,oRestUsrCli:cResult)

		If FWJsonDeserialize(oRestUsrCli:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostUsrCli
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined
@type function
/*/
method PostUsrCli() class MpUsrXClie
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aClie		:= {}

	oRestUsrCli := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadUsrCli() )

	oRestUsrCli:setPath("")
	oRestUsrCli:SetPostParams(cJson)

	If oRestUsrCli:Post(aHeader)
		U_DH05A00L("usuarios_clientes","POST",oRestUsrCli:cHost,cJson)

		nPosID	:= ASCAN(oRestUsrCli:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestUsrCli:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestUsrCli:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestUsrCli:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= oRestUsrCli:oResponseH:cStatusCode
	aClie	:= { Val(cNewId), cNewUrl, cStatus }

return aClie

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostLibCli
//TODO Descrição auto-gerada.
@author Anasol
@since 11/10/2017
@version 1.0
@param nIdVend, numeric, descricao
@param nIdCli, numeric, descricao
@param lBlq, logical, descricao
@type function
/*/
method PostLibCli( nIdVend, nIdCli, lBlq) class MpUsrXClie
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aClie		:= {}

	Default lBlq	:= .T.

	oRestUsrCli := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadLibCli( nIdVend, nIdCli, lBlq) )

	oRestUsrCli:setPath("")
	oRestUsrCli:SetPostParams(cJson)

	If oRestUsrCli:Post(aHeader)
		U_DH05A00L("usuarios_clientes","POST",oRestUsrCli:cHost,cJson)

		nPosID	:= ASCAN(oRestUsrCli:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestUsrCli:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestUsrCli:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestUsrCli:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	Else
		U_DH05A00L("usuarios_clientes","POST",oRestUsrCli:cHost,cJson)
	EndIf

	cStatus	:= oRestUsrCli:oResponseH:cStatusCode
	aClie	:= { Val(cNewId), cNewUrl, cStatus }

return aClie

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadUsrCli
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined
@type function
/*/
Static Function LoadUsrCli()
	Local aRet := {}

	cIdCli		:= AllTrim(SA1->A1_IDMP)
	cIdUser		:= Posicione("SA3", 1, xFilial("SA3") + SA1->A1_VEND,"A3_IDMP")
	cLiberado	:= 'true'

	AADD(aRet,{ "cliente_id"		, cIdCli								, "Integer"	, 0})
	AADD(aRet,{ "usuario_id"		, cIdUser								, "Integer"	, 0})
	AADD(aRet,{ "liberado"			, cLiberado								, "Boolean"	, 0})

Return aRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadLibCli
//TODO Descrição auto-gerada.
@author Anasol
@since 11/10/2017
@version 1.0
@param nIdVend, numeric, descricao
@param nIdCli, numeric, descricao
@param lBlq, logical, descricao
@type function
/*/
Static Function LoadLibCli( nIdVend, nIdCli, lBlq)
	Local aRet := {}

	cIdCli		:= str(nIdCli)
	cIdUser		:= str(nIdVend)
	cLiberado	:= IIF(lBlq,'true','false')

	AADD(aRet,{ "cliente_id"		, cIdCli								, "Integer"	, 0})
	AADD(aRet,{ "usuario_id"		, cIdUser								, "Integer"	, 0})
	AADD(aRet,{ "liberado"			, cLiberado								, "Boolean"	, 0})

Return aRet

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} MontaJson
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined
@param aDados, array, descricao
@type function
/*/
Static Function MontaJson( aDados )
	Local cJson	:= ""
	Local x		:= 0

	cJson := '{'

	For x := 1 to Len(aDados)
		cJson += '"' + aDados[x][1] + '": '

		if aDados[x][3] == 'String'
			if len(aDados[x][2]) > aDados[x][4] .And. aDados[x][4] <> 0
				cJson += '"' + SubStr(aDados[x][2], 1, aDados[x][4]) + '"'
			else
				cJson += '"' + aDados[x][2] + '"'
			endif

		elseif aDados[x][3] == 'Array'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Boolean'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Double'
			cJson += aDados[x][2]

		elseif aDados[x][3] == 'Integer'
			cJson += aDados[x][2]

		endif

		if x < Len(aDados)
			cJson += ', '
		endif

	Next x

	cJson += '}'

Return cJson

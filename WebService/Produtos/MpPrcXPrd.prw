#include 'protheus.ch'

/*/{Protheus.doc} MpPrcXPrd
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpPrcXPrd
	DATA cEntid
	DATA cAppToken
	DATA cEmpToken
	DATA cId
	DATA cUrlBase

	method new() constructor
	method GetPrcXPrd(cId)							// Obtem
	method PostPrcXPrd()							// Incluir
	method PutPrcXPrd(cId)							// Altera

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
method new() class MpPrcXPrd
	::cEntid	:= 'produtos_tabela_preco'
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetPrcXPrd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetPrcXPrd(cId) class MpPrcXPrd
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestXPrd := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestXPrd:setPath("")

	If oRestXPrd:Get(aHeader)
		U_DH05A00L("produtos_tabela_preco","GET",oRestXPrd:cHost,oRestXPrd:cResult)

		If FWJsonDeserialize(oRestXPrd:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

	cStatus	:= oRestXPrd:oResponseH:cStatusCode

return { oRet, cStatus}

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostPrcXPrd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostPrcXPrd() class MpPrcXPrd
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aPrcXPrd		:= {}

	oRestXPrd := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadPrcPrd() )

	oRestXPrd:setPath("")
	oRestXPrd:SetPostParams(cJson)

	If oRestXPrd:Post(aHeader)
		U_DH05A00L("produtos_tabela_preco","POST",oRestXPrd:cHost,cJson)

		nPosID	:= ASCAN(oRestXPrd:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestXPrd:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestXPrd:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestXPrd:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus		:= oRestXPrd:oResponseH:cStatusCode
	aPrcXPrd	:= { Val(cNewId), cNewUrl, cStatus }

return aPrcXPrd

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutPrcXPrd
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutPrcXPrd(cId) class MpPrcXPrd
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aPrcXPrd		:= {}
	Local _y		:= 0

	oRestXPrd := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadPrcPrd() )

	oRestXPrd:setPath("")
	oRestXPrd:SetPostParams(cJson)

	If oRestXPrd:Put( aHeader, cJson)
		U_DH05A00L("produtos_tabela_preco","PUT",oRestXPrd:cHost,cJson)

		nPosID	:= ASCAN(oRestXPrd:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestXPrd:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestXPrd:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestXPrd:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus		:= oRestXPrd:oResponseH:cStatusCode
	aPrcXPrd	:= { Val(cNewId), cNewUrl, cStatus }

return aPrcXPrd

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadPrcXPrd
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadPrcPrd()
	Local aRet := {}

	cIdTabPrc	:= cValToChar(DA0->DA0_IDMP)
	cIdProd		:= cValToChar(Posicione("SB1", 1, xFilial("SB1") + DA1->DA1_CODPRO, "B1_IDMP"))
	cPreco		:= cValToChar(DA1->DA1_PRCVEN)
	cDel		:= 'false'

	AADD(aRet,{ "tabela_id"		, IIF(!Empty(cIdTabPrc), cIdTabPrc, 'null')	, "Integer"	, 0})
	AADD(aRet,{ "produto_id"	, IIF(!Empty(cIdProd), cIdProd, 'null')		, "Integer"	, 0})
	AADD(aRet,{ "preco"			, cPreco									, "Double"	, 0})
	AADD(aRet,{ "excluido"		, cDel										, "Boolean"	, 0})

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

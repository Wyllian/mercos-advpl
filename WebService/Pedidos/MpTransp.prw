#include 'protheus.ch'

/*/{Protheus.doc} MpTransp
(long_description)
@author Wyllian
@since 17/07/2017
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class MpTransp
	DATA cEntid
	DATA cUrlBase
	DATA cAppToken
	DATA cEmpToken
	DATA cId

	method New() constructor
	method GetTrp(cId)							// Obtem
	method PostTrp()							// Incluir
	method PutTrp(cId)							// Alterar

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
method new() class MpTransp
	::cEntid	:= "transportadoras"
	::cAppToken	:= SuperGetMV('DH_APTOKEN')
	::cEmpToken	:= SuperGetMV('DH_CPTOKEN')
	::cUrlBase	:= AllTrim(SuperGetMV('DH_URLMP')) + ::cEntid

return

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} GetTrp
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method GetTrp(cId) class MpTransp
	Local oJson
	Local oRet	:= {}

	Default cId	:= ''

	oRestTrp := FWRest():New(::cUrlBase + IIF(Empty(cId),'','/' + AllTrim(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	oRestTrp:setPath("")

	If oRestTrp:Get(aHeader)
		U_DH05A00L("transportadoras","GET",oRestTrp:cHost,oRestTrp:cResult)

		If FWJsonDeserialize(oRestTrp:cResult, @oJson)
			oRet := oJson
		EndIf
	EndIf

return oRet

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PostTrp
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PostTrp() class MpTransp
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local _y		:= 0
	Local aTrp		:= {}

	oRestTrp := FWRest():New(::cUrlBase)

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadTrp() )

	oRestTrp:setPath("")
	oRestTrp:SetPostParams(cJson)

	If oRestTrp:Post(aHeader)
		U_DH05A00L("transportadoras","POST",oRestTrp:cHost,cJson)

		nPosID	:= ASCAN(oRestTrp:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestTrp:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestTrp:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestTrp:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= oRestTrp:oResponseH:cStatusCode
	aTrp	:= { Val(cNewId), cNewUrl, cStatus }

return aTrp

/*------------------------------------------------------------------------------------------------*/
/*/{Protheus.doc} PutTrp
//TODO Descrição auto-gerada.
@author Wyllian
@since 17/07/2017
@version undefined

@type function
/*/
method PutTrp(cId) class MpTransp
	Local oJson
	Local cJson		:= ""
	Local cNewId	:= ""
	Local cNewUrl	:= ""
	Local aTrp		:= {}
	Local _y		:= 0

	oRestTrp := FWRest():New(::cUrlBase + '/' + AllTrim(cValToChar(cId)))

	aHeader := {}
	Aadd(aHeader, "ApplicationToken: " + ::cAppToken)
	Aadd(aHeader, "CompanyToken: " + ::cEmpToken)
	Aadd(aHeader, "Content-Type: application/json")

	cJson := MontaJson( LoadTrp() )

	oRestTrp:setPath("")
	oRestTrp:SetPostParams(cJson)

	If oRestTrp:Put(aHeader,cJson)
		U_DH05A00L("transportadoras","PUT",oRestTrp:cHost,cJson)

		nPosID	:= ASCAN(oRestTrp:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosID"})
		nPosURL	:= ASCAN(oRestTrp:oResponseH:aHeaderFields,{|x| AllTrim(x[1])=="MeusPedidosURL"})

		If nPosId > 0
			cNewId := alltrim(oRestTrp:oResponseH:aHeaderFields[nPosID][2])
		EndIf

		If nPosURL > 0
			cNewUrl := alltrim(oRestTrp:oResponseH:aHeaderFields[nPosURL][2])
		EndIf
	EndIf

	cStatus	:= oRestTrp:oResponseH:cStatusCode
	aTrp	:= { Val(cNewId), cNewUrl, cStatus }

return aTrp

/* ---------------------------------------------------------------------------------------------- */
/*/{Protheus.doc} LoadTrp
//TODO Descrição auto-gerada.
@author Wyllian
@since 31/07/2017
@version undefined

@type function
/*/
Static Function LoadTrp()
	Local aRet := {}

	cNome		:= AllTrim(SA4->A4_NOME)
	cCidade		:= AllTrim(SA4->A4_MUN)
	cEstado		:= AllTrim(SA4->A4_EST)
	cInfAd		:= ''
	If Empty(SA4->A4_TEL)
		cTelefones	:= '[ '
		cTelefones	+= '{ "numero":" ('+ AllTrim(SA4->A4_DDD) +')'+ AllTrim(SA4->A4_TEL) +'" }'
		cTelefones	+= ' ]'
	Else
		cTelefones := ''
	EndIf
	cDel		:= 'false'

	AADD(aRet,{ "nome"						, cNome										, "String"	, 100})
	AADD(aRet,{ "cidade"					, cCidade									, "String"	, 50})
	AADD(aRet,{ "estado"					, cEstado									, "String"	, 2})
	AADD(aRet,{ "informacoes_adicionais"	, cInfAd									, "String"	, 500})
	If !Empty(cTelefones)
		AADD(aRet,{ "telefones"				, cTelefones								, "Array"	, 0})
	EndIf
	AADD(aRet,{ "excluido"					, cDel										, "Boolean"	, 0})

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
